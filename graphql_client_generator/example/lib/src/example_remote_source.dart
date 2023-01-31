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
