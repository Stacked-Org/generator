import 'package:stacked_generator/src/generators/router/generator/router_generator.dart';
import 'package:stacked_generator/src/generators/router/route_config/adaptive_route_config.dart';
import 'package:stacked_generator/src/generators/router/route_config/cupertino_route_config.dart';
import 'package:stacked_generator/src/generators/router/route_config/custom_route_config.dart';
import 'package:stacked_generator/src/generators/router/route_config/material_route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/importable_type.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_parameter_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/router_config.dart';
import 'package:test/test.dart';

import '../helpers/ast/router_ast_validators.dart';

void main() {
  group('RouteClassGeneratorTest -', () {
    void generateRouteAndExpectStructure(
      List<RouteConfig> routes, {
      bool verbose = false,
      void Function(String)? customValidation,
    }) {
      final routerBaseGenerator = RouterGenerator(RouterConfig(
        routesClassName: 'RoutesTestClassName',
        routerClassName: 'RouterTestClassName',
        generateNavigationHelper: true,
        routes: routes,
      ));
      final result = routerBaseGenerator.generate();

      // ignore: avoid_print
      if (verbose) print(result);
      
      if (customValidation != null) {
        customValidation(result);
      } else {
        // Default validation for complete router generation
        RouteClassGeneratorAstValidator.validateCompleteRouterGeneration(
          result,
          routerClassName: 'RouterTestClassName',
          routesClassName: 'RoutesTestClassName',
          expectedRoutes: routes,
          shouldHaveNavigationExtension: true,
        );
      }
    }

    group(
      'RouteType.material - default -',
      () {
        test('When routes are empty', () {
          List<RouteConfig> routes = [];

          generateRouteAndExpectStructure(
            routes,
            customValidation: (result) {
              expect(result, isEmpty, reason: 'Should generate empty result for no routes');
            },
          );
        });

        test('Given the following RouteConfig, Generate output', () {
          final List<RouteConfig> routes = [
            const MaterialRouteConfig(
              name: 'loginView',
              pathName: 'pathNamaw',
              className: 'TestClass',
              classImport: 'test.dart',
            )
          ];
          
          generateRouteAndExpectStructure(routes);
        });

        test('When adding NestedRouter with one child', () {
          final List<RouteConfig> routes = [
            MaterialRouteConfig(
              name: 'loginView1',
              pathName: 'pathNamaw1',
              className: 'TestClass1',
              classImport: 'test1.dart',
              returnType: ResolvedType(name: 'returnYpe1'),
              children: [
                const MaterialRouteConfig(
                  name: 'nestedView1',
                  pathName: 'nestedPath1',
                  className: 'nestedClass1',
                  classImport: 'nested_test1.dart',
                  parentClassName: 'ParentClass',
                )
              ],
            )
          ];

          generateRouteAndExpectStructure(
            routes,
            customValidation: (result) {
              RouteClassGeneratorAstValidator.validateNestedRouterGeneration(
                result,
                routerClassName: 'RouterTestClassName',
                routesClassName: 'RoutesTestClassName',
                parentRoute: routes.first,
              );
            },
          );
        });

        test('''
When a view parameter inside another data structure,
 Should assign the aliased import to the appropriate type''', () {
          final List<RouteConfig> routes = [
            CustomRouteConfig(
              name: 'loginView',
              pathName: 'pathNamaw',
              className: 'TestClass',
              classImport: 'test.dart',
              parameters: [
                ParamConfig(
                  isPathParam: false,
                  isQueryParam: false,
                  name: 'markers',
                  type: ResolvedType(name: 'List', typeArguments: [
                    ResolvedType(name: 'Marker', import: 'map.dart')
                  ]),
                ),
              ],
            )
          ];

          generateRouteAndExpectStructure(
            routes,
            customValidation: (result) {
              RouteClassGeneratorAstValidator.validateRouterWithAliasedImports(
                result,
                routerClassName: 'RouterTestClassName',
                routesClassName: 'RoutesTestClassName',
                routeWithParameters: routes.first,
              );
            },
          );
        });
        test('When a parameter type is String', () {
          final List<RouteConfig> routes = [
            CustomRouteConfig(
              name: 'loginView',
              pathName: 'pathNamaw',
              className: 'TestClass',
              classImport: 'test.dart',
              parameters: [
                ParamConfig(
                  isPathParam: false,
                  isQueryParam: false,
                  name: 'name',
                  type: ResolvedType(name: 'String', import: 'map.dart'),
                ),
              ],
            )
          ];

          generateRouteAndExpectStructure(
            routes,
            customValidation: (result) {
              RouteClassGeneratorAstValidator.validateRouterWithAliasedImports(
                result,
                routerClassName: 'RouterTestClassName',
                routesClassName: 'RoutesTestClassName',
                routeWithParameters: routes.first,
              );
            },
          );
        });

        group('Mixed -', () {
          test('Given this routing system', () {
            final List<RouteConfig> routes = [
              const CustomRouteConfig(
                name: 'loginView1',
                pathName: 'pathNamaw1',
                className: 'TestClass1',
                classImport: 'test1.dart',
                reverseDurationInMilliseconds: 2,
                durationInMilliseconds: 22,
              ),
              MaterialRouteConfig(
                  name: 'loginView2',
                  pathName: 'pathNamaw2',
                  className: 'TestClass2',
                  classImport: 'test2.dart',
                  parameters: [
                    ParamConfig(
                      name: 'test2paramName',
                      type: ResolvedType(
                          name: 'Test2Type', import: 'test2type.dart'),
                      isPathParam: false,
                      isQueryParam: true,
                    ),
                  ]),
              MaterialRouteConfig(
                  name: 'loginView3',
                  pathName: 'pathNamaw3',
                  className: 'TestClass3',
                  classImport: 'test3.dart',
                  parameters: [
                    ParamConfig(
                      name: 'test3paramName',
                      type: ResolvedType(
                          name: 'Test3Type', import: 'test3type.dart'),
                      isPathParam: false,
                      isQueryParam: false,
                    ),
                  ]),
              const MaterialRouteConfig(
                  name: 'loginView4',
                  pathName: 'pathNamaw4',
                  className: 'TestClass4',
                  classImport: 'test4.dart',
                  maintainState: false),
              const AdaptiveRouteConfig(
                  name: 'loginView5',
                  pathName: 'pathNamaw5',
                  className: 'TestClass5',
                  classImport: 'test5.dart',
                  cupertinoNavTitle: 'cupertinooo'),
              const CupertinoRouteConfig(
                name: 'loginView6',
                pathName: 'pathNamaw6',
                className: 'TestClass6',
                classImport: 'test6.dart',
              ),
            ];

            generateRouteAndExpectStructure(
              routes,
              customValidation: (result) {
                RouteClassGeneratorAstValidator.validateMixedRoutingSystem(
                  result,
                  routerClassName: 'RouterTestClassName',
                  routesClassName: 'RoutesTestClassName',
                  mixedRoutes: routes,
                );
              },
            );
          });
        });
      },
    );
  });
}
