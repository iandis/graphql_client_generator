// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_remote_source.dart';

// **************************************************************************
// GQLClientGenerator
// **************************************************************************

// ignore_for_file: unnecessary_raw_strings
// ignore_for_file: prefer_single_quotes
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: always_specify_types

class _ExampleRemoteSource implements ExampleRemoteSource {
  const _ExampleRemoteSource(this._client);

  final GraphQLClient _client;

  static final _$getExample1Gql = gql(r'''
    query detailDistrict($id: String!) {
      detailDistrict(detailDistrictInput: { districtId: $id }) {
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
      fetchPolicy: FetchPolicy.networkOnly,
      parserFn: Example.fromMap,
    );
    return _client.query(options);
  }

  static final _$getExample2Gql = gql(r'''
    query example {
    ''');
  @override
  Future<QueryResult<Example>> getExample2() {
    final MutationOptions<Example> options = MutationOptions<Example>(
      document: _$getExample2Gql,
      parserFn: Example.fromMap,
    );
    return _client.mutate(options);
  }
}
