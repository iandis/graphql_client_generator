import 'package:graphql/client.dart';
import 'package:graphql_client_annotation/graphql_client_annotation.dart';
import 'package:meta/meta.dart';

@optionalTypeArgs
MyEntity<T> queryResultMapper<T>(QueryResult<T> queryResult) {
  return MyEntity<T>();
}

@optionalTypeArgs
MyEntity<Object> queryResultMapper2<T>(QueryResult<T> queryResult) {
  return MyEntity<Object>();
}

class MyEntity<T> {}

const GQLClient appGQLClient = GQLClient(mapper: queryResultMapper);
