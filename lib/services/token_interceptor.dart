// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hasura_connect/hasura_connect.dart';

class TokenInterceptor extends Interceptor {
  final FirebaseAuth auth;
  TokenInterceptor(this.auth);

  @override
  Future<void> onConnected(HasuraConnect connect) {
     return null;
  }

  @override
  Future<void> onDisconnected() {
     return null;
  }

  @override
  Future onError(HasuraError request) async {
    return request;
  }

  @override
  Future<Request> onRequest(Request request) async {
    var token = await auth.currentUser.getIdToken();
    if (token != null) {
      try {
        request.headers["Authorization"] = "Bearer $token";
        return request;
      } catch (e) {
        return null;
      }
    } else {
    // do something if the token is null 
    }
    return null;
  }

  @override
  Future onResponse(Response data) async {
    return data;
  }

  @override
  Future<void> onSubscription(Request request, Snapshot snapshot) {
    return null;
  }

  @override
  Future<void> onTryAgain(HasuraConnect connect) {
     return null;
  }
}
