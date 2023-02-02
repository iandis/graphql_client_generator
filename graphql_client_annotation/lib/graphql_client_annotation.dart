import 'package:graphql/client.dart';
import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

enum GQLType {
  mutation,
  query,
}

typedef QueryResultMapper = dynamic Function<T>(QueryResult<T> result);

const GQLClient gqlClient = GQLClient();

@Target({TargetKind.classType})
class GQLClient {
  const GQLClient({this.mapper});

  final QueryResultMapper? mapper;
}

@optionalTypeArgs
@Target({TargetKind.method})
class GQL<T> {
  const GQL(
    this.type,
    this.body, {
    required this.parser,
    this.mapper,
    this.name,
    this.fetchPolicy,
  }) : assert(body.length > 0, 'Body must not be empty');

  final GQLType type;
  final String body;
  final T Function(Map<String, dynamic> json) parser;
  final QueryResultMapper? mapper;
  final String? name;
  final FetchPolicy? fetchPolicy;
}

@optionalTypeArgs
@Target({TargetKind.method})
class Mutation<T> extends GQL<T> {
  const Mutation(
    String body, {
    required super.parser,
    super.mapper,
    super.name,
    super.fetchPolicy,
  }) : super(GQLType.mutation, body);
}

@optionalTypeArgs
@Target({TargetKind.method})
class Query<T> extends GQL<T> {
  const Query(
    String body, {
    required super.parser,
    super.mapper,
    super.name,
    super.fetchPolicy,
  }) : super(GQLType.query, body);
}
