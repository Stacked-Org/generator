import 'package:code_builder/code_builder.dart';
import 'package:stacked_generator/src/generators/extensions/string_utils_extension.dart';
import 'package:stacked_generator/src/generators/router_2/code_builder/route_info_builder.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_parameter_config.dart';

mixin RouterExtensionBuilderHelper {
  Iterable<Method> buildNavigateToExtensionMethods(
    List<RouteConfig> routes,
    DartEmitter emitter,
  ) {
    return [
      ...routes.map<Method>(
          (route) => extractNavigateToMethodFromRoute(route, emitter)),
      ...routes.map<Method>(
          (route) => extractReplaceWithMethodFromRoute(route, emitter)),
    ];
  }

  Method extractNavigateToMethodFromRoute(
    RouteConfig route,
    DartEmitter emitter,
  ) =>
      _extractNavigationMethod(
        navigationMethod: 'navigateTo',
        route: route,
        emitter: emitter,
      );

  Method extractReplaceWithMethodFromRoute(
    RouteConfig route,
    DartEmitter emitter,
  ) =>
      _extractNavigationMethod(
        navigationMethod: 'replaceWith',
        route: route,
        emitter: emitter,
      );

  Method _extractNavigationMethod({
    required String navigationMethod,
    required RouteConfig route,
    required DartEmitter emitter,
  }) {
    final methodName = route.parentClassName != null
        ? '${navigationMethod}Nested${route.name?.capitalize}In${route.parentClassName}'
        : '$navigationMethod${route.name?.capitalize}';

    final methodReturnType = route.isProcessedReturnTypeDynamic
        ? route.processedReturnType
        : '${route.processedReturnType}?';

    final viewArgumentsParameter = route.parameters.map(
        (parameter) => _extractViewArgumentsParameters(parameter, emitter));

    return Method((b) => b
      ..name = methodName
      ..modifier = MethodModifier.async
      ..returns = Reference('Future<$methodReturnType>')
      ..optionalParameters.addAll([
        ...viewArgumentsParameter,
        ..._constParameters,
      ])
      ..body = _body(
        route: route,
        methodReturnType: methodReturnType,
        navigationMethod: navigationMethod,
      ));
  }

  /// The arguments provided to the view
  Parameter _extractViewArgumentsParameters(
    ParamConfig param,
    DartEmitter emitter,
  ) {
    return Parameter((parameterBuilder) {
      parameterBuilder
        ..name = param.name
        ..type =
            param is FunctionParamConfig ? param.funRefer : param.type.refer
        ..named = true;

      // Assign default value
      if (param.defaultValueCode != null) {
        parameterBuilder.defaultTo =
            buildCorrectDefaultCode(parameter: param, emitter: emitter);
      }

      // Add required keyword
      if (param.isRequired || param.isPositional) {
        parameterBuilder.required = true;
      }
    });
  }

  /// These are the parameters that exists on every call
  ///
  /// void Function(NavigationFailure)? onFailure,
  List<Parameter> get _constParameters => [
        Parameter(
          (b) => b
            ..name = 'onFailure'
            ..named = true
            ..type = FunctionType((b) => b
              ..symbol = 'Function'
              ..requiredParameters.add(refer(
                'NavigationFailure',
                'package:stacked/stacked.dart',
              ))
              ..isNullable = true
              ..returnType = refer('void')),
        ),
      ];

  Code _body({
    required RouteConfig route,
    required String methodReturnType,
    required String navigationMethod,
  }) {
    var appendOrNotConst = 'const ';
    var appendOrNotParameters = '';

    if (route.parameters.isNotEmpty) {
      appendOrNotConst = '';
      appendOrNotParameters = route.parameters
          .map((p) => '${p.name}: ${p.name},')
          .join('')
          .toString();
    }

    return Block.of([
      Code(
        'return $navigationMethod($appendOrNotConst${route.className}Route($appendOrNotParameters),',
      ),
      ..._constMethodBodyParameters,
    ]);
  }

  List<Code> get _constMethodBodyParameters => [
        const Code('onFailure: onFailure,'),
        const Code(');'),
      ];
}
