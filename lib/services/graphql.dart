import 'package:blue/services/hasura.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Config {
  static final HttpLink httpLink = HttpLink(
    'https://app.stark.social/v1/graphql',
  );
  static final AuthLink authLink =
      AuthLink(getToken: () async => 'Bearer ${Hasura.jwtToken}');
  static final WebSocketLink websocketLink = WebSocketLink(
    'wss://app.stark.social/v1/graphql',
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
      initPayload: () async {
        return {
          'headers': {'Authorization': 'Bearer ${Hasura.jwtToken}'},
        };
      },
    ),
  );
  static final Link link = authLink.concat(httpLink).concat(websocketLink);
  static final Link _link =
      Link.split((request) => request.isSubscription, websocketLink, link);
  static ValueNotifier<GraphQLClient> initailizeClient() {
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: _link,
      ),
    );
    return client;
  }
}
