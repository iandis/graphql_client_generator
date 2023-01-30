import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:graphql/client.dart';
import 'package:graphql_client_annotation/graphql_client_annotation.dart';
import 'package:graphql_client_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

const TypeChecker _gqlMethodChecker = TypeChecker.fromRuntime(GQL);
const TypeChecker _mapChecker = TypeChecker.fromRuntime(Map<String, dynamic>);

class GQLClientGenerator extends GeneratorForAnnotation<GQLClient> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement || !element.isAbstract) {
      throw InvalidGenerationSourceError(
        'The annotated element must be an abstract class.',
        element: element,
      );
    }
    return _generate(element, annotation, buildStep);
  }
}

List<MethodElement> _getGQLMethods(ClassElement clazz) {
  return clazz.methods
      .where((MethodElement element) =>
          _gqlMethodChecker.hasAnnotationOf(element) &&
          element.isAbstract &&
          element.returnType.isDartAsyncFuture)
      .toList(growable: false);
}

String _generate(
  ClassElement clazz,
  ConstantReader annotation,
  BuildStep buildStep,
) {
  final List<MethodElement> gqlMethods = _getGQLMethods(clazz);
  if (gqlMethods.isEmpty) return '';
  final String clazzName = clazz.name;
  final String clazzImplName = '_$clazzName';

  final StringBuffer resultBuffer = StringBuffer()..writeln("""
// ignore_for_file: unnecessary_raw_strings
// ignore_for_file: prefer_single_quotes
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: always_specify_types

class $clazzImplName implements $clazzName {
  const $clazzImplName(this._client);

  final GraphQLClient _client;

""");

  for (final MethodElement method in gqlMethods) {
    _validateParameter(method);
    _validateReturnType(method.returnType);
    final DartObject annotation = _gqlMethodChecker.firstAnnotationOf(
      method,
      throwOnUnresolved: false,
    )!;
    _generateMethod(
      buffer: resultBuffer,
      annotationReader: ConstantReader(annotation),
      hasParameter: method.parameters.isNotEmpty,
      methodName: method.name,
      returnType: method.returnType,
    );
  }

  resultBuffer.writeln('}');
  return resultBuffer.toString();
}

void _validateParameter(MethodElement method) {
  if (method.parameters.isEmpty) return;
  if (method.parameters.length > 1) {
    throw InvalidGenerationSourceError(
      'The annotated method must be a positional parameter of `Map<String, dynamic>.',
      element: method,
    );
  }
  final ParameterElement parameter = method.parameters.first;
  if (!parameter.isPositional ||
      parameter.hasDefaultValue ||
      !_mapChecker.isAssignableFromType(parameter.type)) {
    throw InvalidGenerationSourceError(
      'The annotated method must be a positional parameter of `Map<String, dynamic>.',
      element: method,
    );
  }
}

void _validateReturnType(DartType returnType) {
  if (!const TypeChecker.fromRuntime(Future<QueryResult<Object?>>)
      .isAssignableFromType(returnType)) {
    throw InvalidGenerationSourceError(
      'The annotated method must return a `Future<QueryResult>`.',
      element: returnType.element,
    );
  }
}

void _generateMethod({
  required StringBuffer buffer,
  required ConstantReader annotationReader,
  required bool hasParameter,
  required String methodName,
  required DartType returnType,
}) {
  final ConstantReader gqlNameReader = annotationReader.read('name');
  final String? gqlName =
      gqlNameReader.isNull ? null : gqlNameReader.stringValue;

  final String gqlBody = annotationReader.read('body').stringValue;

  final GQLType gqlType = GQLType.values.firstWhere((GQLType type) =>
      type.name == annotationReader.read('type').read('_name').stringValue);

  final ConstantReader fetchPolicyReader = annotationReader.read('fetchPolicy');
  final FetchPolicy? gqlFetchPolicy = !fetchPolicyReader.isNull
      ? FetchPolicy.values.firstWhere((FetchPolicy policy) =>
          policy.name == fetchPolicyReader.read('_name').stringValue)
      : null;

  final String staticFieldName = _createStaticGQLDocumentField(
    buffer: buffer,
    gqlBody: gqlBody,
    methodName: methodName,
  );
  final String returnTypeName = returnType.getDisplayString(
    withNullability: false,
  );
  final String parserFunctionName = _getParserFunctionName(annotationReader);
  final String resultType = _getResultType(returnType);
  final String parameterName =
      hasParameter ? 'Map<String, dynamic> variables' : '';
  buffer.writeln(
    '''  @override
  $returnTypeName $methodName($parameterName) {''',
  );
  switch (gqlType) {
    case GQLType.mutation:
      buffer.writeln(
        '    final MutationOptions<$resultType> options = MutationOptions<$resultType>(',
      );
      break;
    case GQLType.query:
      buffer.writeln(
        '    final QueryOptions<$resultType> options = QueryOptions<$resultType>(',
      );
      break;
  }

  _fillOptions(
    buffer: buffer,
    gqlName: gqlName,
    gqlFetchPolicy: gqlFetchPolicy,
    hasParameter: hasParameter,
    staticFieldName: staticFieldName,
    parserFunctionName: parserFunctionName,
  );

  switch (gqlType) {
    case GQLType.mutation:
      buffer.writeln(
        '''    );
    return _client.mutate(options);''',
      );
      break;
    case GQLType.query:
      buffer.writeln(
        '''    );
    return _client.query(options);''',
      );
      break;
  }

  buffer.writeln('  }');
}

String _createStaticGQLDocumentField({
  required StringBuffer buffer,
  required String gqlBody,
  required String methodName,
}) {
  final String staticFieldName = '_\$${methodName}Gql';
  buffer
    ..writeln(" static final $staticFieldName = gql(r'''")
    ..writeln("$gqlBody''');");
  return staticFieldName;
}

void _fillOptions({
  required StringBuffer buffer,
  required String? gqlName,
  required FetchPolicy? gqlFetchPolicy,
  required bool hasParameter,
  required String staticFieldName,
  required String parserFunctionName,
}) {
  final String? operationName = gqlName != null ? "'$gqlName'" : null;
  if (operationName != null) {
    buffer.writeln('      operationName: $operationName,');
  }
  buffer.writeln('      document: $staticFieldName,');
  if (hasParameter) {
    buffer.writeln('      variables: variables,');
  }
  if (gqlFetchPolicy != null) {
    buffer.writeln('      fetchPolicy: $gqlFetchPolicy,');
  }
  buffer.writeln('      parserFn: $parserFunctionName,');
}

String _getParserFunctionName(ConstantReader annotationReader) {
  return annotationReader
      .read('parser')
      .objectValue
      .toFunctionValue()!
      .qualifiedName;
}

String _getResultType(DartType returnType) {
  final ParameterizedType parameterizedType = returnType as ParameterizedType;
  final DartType queryResultType = parameterizedType.typeArguments.first;
  final ParameterizedType queryResultParameterizedType =
      queryResultType as ParameterizedType;
  final DartType queryResultData =
      queryResultParameterizedType.typeArguments.first;
  return queryResultData.getDisplayString(withNullability: false);
}
