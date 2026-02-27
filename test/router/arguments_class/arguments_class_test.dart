import 'package:code_builder/code_builder.dart';
import 'package:stacked_generator/src/generators/router/generator/arguments_class/arguments_class_builder.dart';
import 'package:stacked_generator/src/generators/router/route_config/material_route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/importable_type.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_parameter_config.dart';
import 'package:test/test.dart';

import '../../helpers/class_extension.dart';

final List<RouteConfig> _routes = [
  MaterialRouteConfig(
      name: 'loginView',
      pathName: 'pathNamaw',
      className: 'LoginClass',
      classImport: 'ui/login_class.dart',
      parameters: [
        ParamConfig(
          isPathParam: false,
          isQueryParam: false,
          isPositional: true,
          name: 'position',
          type: ResolvedType(name: 'Marker', import: 'marker.dart'),
        ),
        ParamConfig(
          isPathParam: false,
          isQueryParam: false,
          name: 'age',
          type: ResolvedType(name: 'int'),
        )
      ]),
  MaterialRouteConfig(
      name: 'homeView',
      pathName: '/family/:fid',
      className: 'HomeClass',
      classImport: 'ui/home_class.dart',
      parameters: [
        ParamConfig(
          isPathParam: false,
          isQueryParam: false,
          isPositional: true,
          name: 'car',
          type: ResolvedType(name: 'Car', import: 'car.dart'),
        ),
        ParamConfig(
          isPathParam: false,
          isQueryParam: false,
          name: 'age',
          type: ResolvedType(name: 'int'),
        ),
        ParamConfig(
          isPathParam: false,
          isQueryParam: false,
          name: 'color',
          type: ResolvedType(name: 'String'),
        )
      ])
];

void main() {
  group('ArgumentClassBuilderHelperTest -', () {
    Iterable<Class> getBuilderInstance() => ArgumentsClassBuilder(
          routes: _routes,
        ).buildViewsArguments(DartEmitter());

    group('addRoutesClassName -', () {
      test('Should generate argument classes', () {
        final builder = getBuilderInstance();
        final generatedCode = builder.buildLibraryForClass;

        // Basic AST validation for argument classes
        expect(generatedCode.trim(), isNotEmpty, reason: 'Should generate non-empty code');
        expect(generatedCode, contains('class LoginClassArguments'), reason: 'Should contain LoginClassArguments class');
        expect(generatedCode, contains('class HomeClassArguments'), reason: 'Should contain HomeClassArguments class');
        expect(generatedCode, contains('const LoginClassArguments'), reason: 'Should have const constructor for LoginClassArguments');
        expect(generatedCode, contains('const HomeClassArguments'), reason: 'Should have const constructor for HomeClassArguments');
        expect(generatedCode, contains('final'), reason: 'Should have final fields for parameters');
      });
    });
  });
}
