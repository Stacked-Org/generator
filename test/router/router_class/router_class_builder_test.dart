import 'package:stacked_generator/src/generators/router/generator/router_class/router_class_builder.dart';
import 'package:stacked_generator/src/generators/router/route_config/material_route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:test/test.dart';

import '../../helpers/class_extension.dart';
import '../../helpers/ast/router_ast_validators.dart';

final List<RouteConfig> _routes = [
  const MaterialRouteConfig(
    name: 'loginView',
    pathName: 'pathNamaw',
    className: 'LoginClass',
    classImport: 'ui/login_class.dart',
  ),
  const MaterialRouteConfig(
    name: 'homeView',
    pathName: '/family/:fid',
    className: 'HomeClass',
    classImport: 'ui/home_class.dart',
  )
];

void main() {
  group('RouterClassBuilderTest -', () {
    group('Router Class Generation -', () {
      test('Should generate valid router class structure', () {
        final builder = RouterClassBuilder(
          routes: _routes,
          routesClassName: 'RoutesClassName',
          routerClassName: 'RouterClassName',
        ).buildRouterClass();

        final generatedCode = builder.buildLibraryForClass;

        // AST-based validation instead of string comparison
        RouterAstValidator.validateRouterClassStructure(
          generatedCode,
          expectedClassName: 'RouterClassName',
          expectedSuperclass: 'RouterBase',
        );
      });

      test('Should include required imports', () {
        final builder = RouterClassBuilder(
          routes: _routes,
          routesClassName: 'RoutesClassName',
          routerClassName: 'RouterClassName',
        ).buildRouterClass();

        final generatedCode = builder.buildLibraryForClass;

        RouterAstValidator.validateRequiredImports(
          generatedCode,
          requiredImports: [
            'package:stacked/stacked.dart',
            'ui/login_class.dart',
            'ui/home_class.dart',
          ],
        );
      });

      test('Should generate correct field structures', () {
        final builder = RouterClassBuilder(
          routes: _routes,
          routesClassName: 'RoutesClassName',
          routerClassName: 'RouterClassName',
        ).buildRouterClass();

        final generatedCode = builder.buildLibraryForClass;

        RouterAstValidator.validateRoutesField(
          generatedCode,
          expectedRouteCount: _routes.length,
        );

        RouterAstValidator.validatePagesMapField(
          generatedCode,
          expectedPageCount: _routes.length,
        );
      });

      test('Should generate correct getter methods', () {
        final builder = RouterClassBuilder(
          routes: _routes,
          routesClassName: 'RoutesClassName',
          routerClassName: 'RouterClassName',
        ).buildRouterClass();

        final generatedCode = builder.buildLibraryForClass;

        RouterAstValidator.validateGetterMethods(generatedCode);
      });
    });
  });
}
