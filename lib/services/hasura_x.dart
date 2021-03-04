import 'dart:async';
import 'package:meta/meta.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:http/http.dart' as http;

// problem:
// when subscribing to`HasuraConnect.subscription`, a websocket connection is created on the first subscription
// call. The websocket connection is created only once with the initial subscription and the provided TokenInterceptor
// or headers. When the token expires during an active subscription, HasuraConnect doesn't stop the subscription, or try
// to reconnect with the latest token in in the TokenInterceptor nor does it throw an error. It'll keep calling `onRequest` 
// method indefinitely for some reason as it was observed in the TokenInterceptor. 

// solution:
// When all active subscription are closed (ie Snapshot.close()), HasuraConnect will terminate the websocket connection
// The following implementation does exactly that and then reconnect again to create a websocket connection with the latest
// token interceptor. ALl this while keeping subscription alive. Here's how:
// - For each subscription, return a SnapshotX object and keep a reference to the object (currentSnapshots).
// - The SnapshotX object is fed by a source Snapshot that's updatable.
// - listen to an auth stream provided by the user.
// - when the auth stream sends an event, all source snapshots are closed (hence HasuraConnect closes websocket connection)
// - recreate all source snapshots and update each subscription (SnapshotX) with a new source snapshot
// - when recreating the new snapshots, hasura will use the latest Token available in the TokenInterceptor
//   and recreate a new websocket connection.  
// 
// this way the user stream/subscription stays alive and all this process happens in the background as shown in the code below.


/// usage:
/// ```dart
/// // import this file 
/// import '../hasura_connect_ex.dart';
///
/// final hasuraClient = HasuraConnectX(
///   url,
///   // use your own TokenInterceptor per hasura_connect docs
///   interceptors: [TokenInterceptor(tokenProvider: tokenProvider)],
///   // you can pass firebase stream onAuthStateChanged here, or any stream that trigers when token is updated. 
///   onAuthStateChanged: tokenProvider(),
/// );
/// 
/// 
/// final snapshot = await hasuraClient.subscriptionX(docSubscription); // this will return SnapshotX 
/// 
/// // you can use it the same way as hasuraClient.subscription:
/// // map and listen
/// snapshot.map((event) {....} )listen((event) { ... });
/// 
/// // change variables
/// snapshot.changeVariables(variables);
/// 
/// // close snapshot 
/// snapshot.close();
/// ```
// an extended HasuraConnect that updates subscription based on an auth stream.
// make sure you've an TokenInterceptor in place in order for this implementation to work.
class HasuraConnectX extends HasuraConnect {
  HasuraConnectX(
    String url, {
    @required Stream onAuthStateChanged,
    int reconnectionAttemp,
    List<Interceptor> interceptors,
    Map<String, String> headers,
    http.Client httpClient,
  }) : super(
          url,
          reconnectionAttemp: reconnectionAttemp,
          interceptors: interceptors,
          headers: headers,
          httpClient: httpClient,
        ) {
    // skip the first event since it'll not indicate an actual change in the Auth State
    authStateSubscription = onAuthStateChanged.skip(1).listen((event) {
      // to avoid unncessary connections/disconnetions
      // another option is to pause authStateSubscription when currentSnapshots.isEmpty
      if (currentSnapshots.isNotEmpty) {
        //print('refreshing ${currentSnapshots.length} snapshot(s) from HasuraConnectX');
        refreshSubscriptions();
      }
    });
  }
  // this can be any stream that sends events whenever auth state changed (the evnets are not read)
  // make sure the TokenInterceptor always has an up to date token because HasuraConnect will use that create a the new
  // websocket connection
  StreamSubscription authStateSubscription;
  // a map for the current snapshots that to be updated when Auth State Changed
  final Map<String, SnapshotX<Object>> currentSnapshots = {};

  // a wrapper around HasuraConnect subscription
  Future<SnapshotX> subscriptionX(String document, {String key, Map<String, dynamic> variables}) async {
    final snapshot = await super.subscription(document, key: key, variables: variables);
    // if the key is not provided, use the one created by hasuraClient.subscription
    key ??= snapshot.query.key;

    currentSnapshots[key] = SnapshotX(
      sourceSnapshot: snapshot,
      onClose: () => currentSnapshots.remove(key),
      onMap: (newSnapshotX) => currentSnapshots[key] = newSnapshotX,
    );
    
    return currentSnapshots[key];
  }

  void refreshSubscriptions() async {
    // when disconnect is called, hasuraClient will close all the active snapshots.
    // the disconnection process includes futures + a 300 ms Future.delayed.
    await disconnect();

    _recreateSnapshots();
  }

  // recreate all the snapshots that are still active based on currentSnapshots map
  void _recreateSnapshots() {
    // print('recreating connections....');
    for (var key in currentSnapshots.keys) {
      final intermediateSnapshot = currentSnapshots[key];
      subscription(
        intermediateSnapshot.document,
        key: intermediateSnapshot.key,
        variables: intermediateSnapshot.variables,
      ).then((newSnapshot) => intermediateSnapshot.updateSourceSnapshot(newSnapshot));
    }
  }

  @override
  Future<void> dispose() async {
    // no need to call disconnect, super.dispose() already does
    await authStateSubscription?.cancel();
    return super.dispose();
  }
}

// note: I tried initially to extend the Snapshot class but that didn't go well since Snapshot has a constructor body
// that does its own shenanigans
// this class mainly keeps the sourceSnapshot and pipe its event to a stream that can be used by the user.
class SnapshotX<T> {
  // keep dynamic without generic types otherwise it'll throw an error when updating (because snapshots comes as dynamic)
  Snapshot sourceSnapshot;
  final void Function() onClose;
  final void Function(SnapshotX newSnapshotX) onMap;

  // controller should be dynamic because when the snapshot is mapped, the Type will change.
  // rootStream will take care of mapping the stream of the controller into the new types without changing the controller
  // controller and rootstream are mutable because they are assigned based on two cases:
  // - in a new snapshot case, will initialize a streamcontroller and pass its stream to rootStream
  // - in a mapping case, controller and roostream are passed from the previous snapshot (see `map` method)
  StreamController controller;
  Stream<T> rootStream;

  // used to update the snapshot with the same query.
  final String key; 
  final String document; 
  Map<String, dynamic> variables;

  SnapshotX({
    @required this.sourceSnapshot,
    @required this.onClose,
    @required this.onMap,
    StreamController controller,
    Stream<T> rootStream,
  })  : key = sourceSnapshot.query.key,
        document = sourceSnapshot.query.document,
        variables = sourceSnapshot.query.variables {
    // TODO: should convert to a broadcast stream instead?
    this.controller = controller ?? StreamController(onListen: _pipe, onCancel: _onCancel);
    this.rootStream = rootStream ?? this.controller.stream;
  }

  Future<void> changeVariables(Map<String, dynamic> variables) async {
    this.variables = variables;
    // to keep the latest variables up to date on currentSnapshots map
    onMap(this);
    // HasuraConnect will take care of changing the variables and updating the sourceSnapshot internally.
    await sourceSnapshot.changeVariables(variables);
  }

  void updateSourceSnapshot(Snapshot snapshot) {
    // update the source snapshot with the new snapshot
    sourceSnapshot = snapshot;
    // cancel the previous subscription
    _sourceSnapshotSubscription?.cancel();
    // pipe the new snapshot to create a new subscription
    _pipe();
  }

  // a subscription to the source snapshot
  StreamSubscription _sourceSnapshotSubscription;
  // to keep track if data changed between connecting and disconnecting
  dynamic latestEvent;

  // pipe events from sourceSnapshot to this Snapshot.
  // the following approach is naive but does the job and avoids closing/pausing the stream or creating a complex one.
  void _pipe() {
    _sourceSnapshotSubscription = sourceSnapshot.listen((event) {
      // check if the last event before disconnecting is still the same after reconnecting
      // note: (latestEvent == event) always returns false.
      // comment it out if not desired.
      if (latestEvent.toString() == event.toString()) return;
      latestEvent = event;
      controller.add(event);
    });
    _sourceSnapshotSubscription.onError(controller.addError);
  }

  // when a user maps the stream, return a new SnapshotX instance
  // we return SnapshotX instead of a stream mainly to expose `changeVariables` method
  SnapshotX<S> map<S>(S Function(T event) convert) {
    final newSnapshotX = SnapshotX<S>(
      sourceSnapshot: sourceSnapshot.map<S>(convert),
      rootStream: rootStream.map(convert),
      onClose: onClose,
      onMap: onMap,
      controller: controller,
    );
    // update the map of currentSnapshots with the new mapped instance
    onMap?.call(newSnapshotX);
    return newSnapshotX;
  }

  // when a user stops listening, cancel the subscription to the source snapshot.
  void _onCancel() {
    _sourceSnapshotSubscription?.cancel();
  }

  // the user must close the snapshot after consuming it.
  void close() {
    _onCancel();
    sourceSnapshot.close();
    controller.close();
    onClose?.call();
  }

  // listen to the rootStream which has the latest mapping (don't listen to stream controller directly)
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return rootStream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}