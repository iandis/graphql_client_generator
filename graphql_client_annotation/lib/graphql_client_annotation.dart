import 'package:graphql/client.dart';
import 'package:meta/meta_meta.dart';

enum GQLType {
  mutation,
  query,
}

const GQLClient gqlClient = GQLClient();

@Target({TargetKind.classType})
class GQLClient {
  const GQLClient();
}

@Target({TargetKind.method})
class GQL {
  const GQL(
    this.type,
    this.body, {
    required this.parser,
    this.name,
    this.fetchPolicy,
  }) : assert(body.length > 0, 'Body must not be empty');

  final GQLType type;
  final String body;
  final String? name;
  final FetchPolicy? fetchPolicy;
  final Object? Function(Map<String, dynamic> json) parser;
}

@Target({TargetKind.method})
class Mutation extends GQL {
  const Mutation(
    String body, {
    required super.parser,
    super.name,
    super.fetchPolicy,
  }) : super(GQLType.mutation, body);
}

@Target({TargetKind.method})
class Query extends GQL {
  const Query(
    String body, {
    required super.parser,
    super.name,
    super.fetchPolicy,
  }) : super(GQLType.query, body);
}
