import 'package:build/build.dart';
import 'package:graphql_client_generator/src/gql_client_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder gqlClientBuilder(BuilderOptions options) {
  return PartBuilder([GQLClientGenerator()], '.gqlc.dart');
}
