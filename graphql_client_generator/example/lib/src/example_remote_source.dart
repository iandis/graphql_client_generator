import 'package:example/src/example.dart';
import 'package:graphql/client.dart';
import 'package:graphql_client_annotation/graphql_client_annotation.dart';

part 'example_remote_source.gqlc.dart';

@gqlClient
abstract class ExampleRemoteSource {
  const factory ExampleRemoteSource(
    GraphQLClient client,
  ) = _ExampleRemoteSource;

  @Query(
    parser: Example.fromMap,
    fetchPolicy: FetchPolicy.networkOnly,
    r'''
    query detailDistrict($id: String!) {
      detailDistrict(detailDistrictInput: { districtId: $id }) {
        id
        name
      }
    }
    ''',
  )
  Future<QueryResult<Example>> getExample1(Map<String, dynamic> variables);

  @Mutation(
    parser: Example.fromMap,
    r'''
    query example {
    ''',
  )
  Future<QueryResult<Example>> getExample2();
}
