import 'package:code_builder/code_builder.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:stacked_generator/utils.dart';

import 'argument_class_builder_helper.dart';

class ArgumentsClassBuilder {
  final List<RouteConfig> routes;

  const ArgumentsClassBuilder({required this.routes});

  Iterable<Class> buildViewsArguments(DartEmitter emitter) {
    final routesWithParameters = routes.where(
      (route) => notQueryNorPath(route.parameters).isNotEmpty,
    );

    return routesWithParameters.map((route) {
      final argumentsBuilderHelper = ArgumentClassBuilderHelper(route);

      final argumentsAsMap = argumentsBuilderHelper.convertArgumentsToMap;

      return Class(
        (b) => b
          ..name = argumentsBuilderHelper.argumentClassName
          ..fields.addAll(argumentsBuilderHelper.convertParametersToClassFields)
          ..constructors.add(
            argumentsBuilderHelper.argumentConstructer(emitter),
          )
          ..methods.addAll([
            Method(
              (b) => b
                ..annotations.add(refer('override'))
                ..name = 'toString'
                ..body = Code("return '$argumentsAsMap';")
                ..returns = TypeReference(
                  (b) => b..symbol = 'String',
                ),
            ),
            _buildEqualityOperator(
              className: argumentsBuilderHelper.argumentClassName,
              fields: argumentsBuilderHelper.convertParametersToClassFields,
            ),
            _buildHashCode(
              argumentsBuilderHelper.convertParametersToClassFields,
            ),
          ]),
      );
    });
  }
}

Method _buildHashCode(List<Field> fields) {
  final buffer = StringBuffer();
  buffer.writeln(
    'return ${fields.map((f) => '${f.name}.hashCode').join(' ^ ')};',
  );

  return Method(
    (b) => b
      ..name = 'hashCode'
      ..returns = refer('int')
      ..annotations.add(refer('override'))
      ..type = MethodType.getter
      ..body = Code(buffer.toString().trim()),
  );
}

Method _buildEqualityOperator({
  required String className,
  required List<Field> fields,
}) {
  final buffer = StringBuffer();
  buffer.writeln('if (identical(this, other)) return $literalTrue;');
  buffer.writeln(
    'return ${fields.map((f) => 'other.${f.name} == ${f.name}').join(' && ')};',
  );

  return Method(
    (b) => b
      ..name = 'operator =='
      ..returns = refer('bool')
      ..annotations.add(refer('override'))
      ..requiredParameters.add(Parameter((p) => p
        ..covariant = true
        ..name = 'other'
        ..type = refer(className)))
      ..body = Code(buffer.toString()),
  );
}
