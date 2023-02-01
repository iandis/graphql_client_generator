Generates opinionated graphql client annotated classes and methods defined by [graphql_client_annotation](https://pub.dev/packages/graphql_client_annotation) for generating opinionated graphql client class.

The annotated classes must depend on `GraphQLClient` from [this package](https://pub.dev/packages/graphql) in order to generate successfully.

## Setup

To configure your project for the latest released version of `graphql_client_generator`, see the [example](https://github.com/iandis/graphql_client_generator/tree/main/graphql_client_generator/example).

## Example

Given an entity class `Example` and a graphql client class `ExampleRemoteSource` annotated with `gqlClient`:

```dart
import 'package:graphql/client.dart';
import 'package:graphql_client_annotation/graphql_client_annotation.dart';

part 'example_remote_source.gqlc.dart';

@gqlClient
abstract class ExampleRemoteSource {
  const factory ExampleRemoteSource(
    GraphQLClient client,
  ) = _ExampleRemoteSource;

  @Query(
    parser: Example.fromJson,
    r'''
    query detailExample($id: String!) {
      detailExample(detailExampleInput: { exampleId: $id }) {
        id
        name
      }
    }
    ''',
  )
  Future<QueryResult<Example>> getExample1(Map<String, dynamic> variables);
}
```

Building creates the corresponding part `example_remote_source.gqlc.dart`:

```dart
part of 'example_remote_source.dart';

class _ExampleRemoteSource implements ExampleRemoteSource {
  const _ExampleRemoteSource(this._client);

  final GraphQLClient _client;

  static final _$getExample1Gql = gql(r'''
    query detailExample($id: String!) {
      detailExample(detailExampleInput: { exampleId: $id }) {
        id
        name
      }
    }
    ''');
  @override
  Future<QueryResult<Example>> getExample1(Map<String, dynamic> variables) {
    final QueryOptions<Example> options = QueryOptions<Example>(
      document: _$getExample1Gql,
      variables: variables,
      parserFn: Example.fromJson,
    );
    return _client.query(options);
  }
```

## Running the code generator

Once you have added the annotations to your code you then need to run the code generator to generate the missing `.gqlc.dart` generated dart files.

With a Dart package, run dart run build_runner build in the package directory.

With a Flutter package, run flutter pub run build_runner build in your package directory.

## Annotation values

Each target class must be an **abstract class** and annotated with `GQLClient` or the premade one `gqlClient`, and each method that will consume the `GraphQLClient` must be annotated either with `Mutation` or `Query`.

The generated code for each annotated methods will have a default return value of `Future<QueryResult<YourEntity>>`, where `YourEntity` is the class that is expected to be created by `parser` you defined in `Mutation` or `Query`.

For customizing the return value, you can define `mapper` either in `GQLClient` or in `Mutation`/`Query`. For example:

Given a library `app_gql_client.dart`:

```dart
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
```

And an abstract class `ExampleRemoteSource`:

```dart
import 'package:example/src/app_gql_client.dart';
import 'package:example/src/example.dart';
import 'package:graphql/client.dart';
import 'package:graphql_client_annotation/graphql_client_annotation.dart';

part 'example_remote_source.gqlc.dart';

@appGQLClient
abstract class ExampleRemoteSource {
  const factory ExampleRemoteSource(
    GraphQLClient client,
  ) = _ExampleRemoteSource;

  @Query(
    parser: Example.fromMap,
    fetchPolicy: FetchPolicy.networkOnly,
    r'''
    query detailExample($id: String!) {
      detailExample(detailExampleInput: { exampleId: $id }) {
        id
        name
      }
    }
    ''',
  )
  Future<MyEntity<Example>> getExample1(Map<String, dynamic> variables);

  @Mutation(
    parser: Example.fromMap,
    mapper: queryResultMapper2,
    r'''
    query example {
    ''',
  )
  Future<MyEntity<Object>> getExample2();
}
```

Building creates the corresponding part `example_remote_source.gqlc.dart`:

```dart
part of 'example_remote_source.dart';

class _ExampleRemoteSource implements ExampleRemoteSource {
  const _ExampleRemoteSource(this._client);

  final GraphQLClient _client;

  static final _$getExample1Gql = gql(r'''
    query detailExample($id: String!) {
      detailExample(detailExampleInput: { exampleId: $id }) {
        id
        name
      }
    }
    ''');
  @override
  Future<MyEntity<Example>> getExample1(Map<String, dynamic> variables) {
    final QueryOptions<Example> options = QueryOptions<Example>(
      document: _$getExample1Gql,
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
      parserFn: Example.fromMap,
    );
    return _client.query(options).then(queryResultMapper);
  }

  static final _$getExample2Gql = gql(r'''
    query example {
    ''');
  @override
  Future<MyEntity<Object>> getExample2() {
    final MutationOptions<Example> options = MutationOptions<Example>(
      document: _$getExample2Gql,
      parserFn: Example.fromMap,
    );
    return _client.mutate(options).then(queryResultMapper2);
  }
}
```
