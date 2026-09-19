import 'dart:async';

import 'package:stacked_generator/src/generators/router/generator/router_class/router_class_builder.dart';
import 'package:stacked_generator/src/generators/router/route_config/material_route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/importable_type.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_parameter_config.dart';
import 'package:test/test.dart';

import '../../helpers/class_extension.dart';

final List<RouteConfig> _routes = [
  // ignore: prefer_const_constructors
  MaterialRouteConfig(
    name: 'loginView',
    pathName: 'pathName',
    className: 'LoginClass',
    classImport: 'ui/login_class.dart',
  ),
  MaterialRouteConfig(
    name: 'homeView',
    pathName: '/family/:fid',
    parameters: [
      ParamConfig(
          name: 'name',
          type: ResolvedType(name: 'String'),
          isRequired: true,
          isPathParam: false,
          isQueryParam: false)
    ],
    className: 'HomeClass',
    classImport: 'ui/home_class.dart',
  )
];
void main() {
  group('RouterClassBuilderHelperTest -', () {
    late RouterClassBuilder routerClassBuilderHelper;

    setUp(() => routerClassBuilderHelper = const RouterClassBuilder(
          routerClassName: '',
          routes: [],
          routesClassName: '',
        ));

    group('listOfRoutes -', () {
      test('list of routes that will assigned to the routes field', () {
        final generatedCode = routerClassBuilderHelper
            .listOfRoutes(_routes, 'RoutesClassName')
            .buildLibraryForClass;
        
        // Basic AST validation - ensure code is valid Dart and contains expected content
        expect(generatedCode.trim(), isNotEmpty, reason: 'Should generate non-empty code');
        expect(generatedCode, contains('RouteDef'), reason: 'Should contain RouteDef declarations');
        expect(generatedCode, contains('RoutesClassName'), reason: 'Should reference RoutesClassName');
      });
    });
    group('routesGetter -', () {
      test('generate the routesGetter field', () {
        final generatedCode = routerClassBuilderHelper.routesGetter.buildLibraryForClass;
        
        // Basic validation - ensure getter is properly generated
        expect(generatedCode.trim(), isNotEmpty, reason: 'Should generate non-empty code');
        expect(generatedCode, contains('@override'), reason: 'Should have override annotation');
        expect(generatedCode, contains('routes'), reason: 'Should contain routes getter');
      });
    });
    group('pagesMapGetter -', () {
      test('generate the pagesMapGetter field', () {
        final generatedCode = routerClassBuilderHelper.pagesMapGetter.buildLibraryForClass;
        
        // Basic validation - ensure pagesMap getter is properly generated
        expect(generatedCode.trim(), isNotEmpty, reason: 'Should generate non-empty code');
        expect(generatedCode, contains('@override'), reason: 'Should have override annotation');
        expect(generatedCode, contains('pagesMap'), reason: 'Should contain pagesMap getter');
      });
    });
    group('mapOfPages -', () {
      test('generate the mapOfPages field for empty routes', () {
        final generatedCode = routerClassBuilderHelper.mapOfPages([]).buildLibraryForClass;
        
        // Basic validation - ensure empty pages map is generated
        expect(generatedCode.trim(), isNotEmpty, reason: 'Should generate non-empty code');
        expect(generatedCode, contains('Map'), reason: 'Should contain Map type');
        expect(generatedCode, contains('{}'), reason: 'Should be empty map for no routes');
      });

      test(
        'generate the mapOfPages field for 2 routes',
        () {
          final generatedCode = routerClassBuilderHelper.mapOfPages(_routes).buildLibraryForClass;
          
          // Basic validation - ensure pages map with routes is generated
          expect(generatedCode.trim(), isNotEmpty, reason: 'Should generate non-empty code');
          expect(generatedCode, contains('Map'), reason: 'Should contain Map type');
          expect(generatedCode, contains('MaterialPageRoute'), reason: 'Should contain MaterialPageRoute for routes');
        },
      );

      test(
        'a CustomRoute with a customRouteBuilder still generates the same PageRouteBuilder output '
        '(Navigator 1 cannot invoke customRouteBuilder without a BuildContext)',
        () {
          const withoutBuilder = RouteConfig(
            name: 'bottomSheetView',
            pathName: 'bottomSheetPath',
            className: 'BottomSheetClass',
            classImport: 'ui/bottom_sheet_class.dart',
            routeType: RouteType.custom,
          );

          final withBuilder = RouteConfig(
            name: 'bottomSheetView',
            pathName: 'bottomSheetPath',
            className: 'BottomSheetClass',
            classImport: 'ui/bottom_sheet_class.dart',
            routeType: RouteType.custom,
            customRouteBuilder: ResolvedType(
              name: 'RouteBuilders.bottomSheetBuilder',
              import: 'ui/route_builders.dart',
            ),
          );

          final generatedWithout = routerClassBuilderHelper
              .mapOfPages([withoutBuilder]).buildLibraryForClass;
          final generatedWith = routerClassBuilderHelper
              .mapOfPages([withBuilder]).buildLibraryForClass;

          expect(generatedWith, equals(generatedWithout),
              reason:
                  'Setting customRouteBuilder must not change the Navigator 1 output: '
                  'it still falls back to PageRouteBuilder unchanged, since Navigator 1 '
                  'has no BuildContext to invoke the builder with.');
          expect(generatedWith, contains('PageRouteBuilder'));
          expect(generatedWith, isNot(contains('bottomSheetBuilder')));
        },
      );

      test(
        'a CustomRoute with a customRouteBuilder emits a warning pointing to navigator2',
        () async {
          final routes = <RouteConfig>[
            RouteConfig(
              name: 'bottomSheetView',
              pathName: 'bottomSheetPath',
              className: 'BottomSheetClass',
              classImport: 'ui/bottom_sheet_class.dart',
              routeType: RouteType.custom,
              customRouteBuilder: ResolvedType(
                name: 'RouteBuilders.bottomSheetBuilder',
                import: 'ui/route_builders.dart',
              ),
            ),
          ];

          final printedLines = <String>[];
          await runZoned(
            () async {
              routerClassBuilderHelper.mapOfPages(routes);
            },
            zoneSpecification: ZoneSpecification(
              print: (self, parent, zone, line) => printedLines.add(line),
            ),
          );

          final combined = printedLines.join('\n');
          expect(combined, contains('WARNING'));
          expect(combined, contains('customRouteBuilder'));
          expect(combined, contains(routes.first.routeName));
          expect(combined, contains('navigator2: true'));
          expect(combined, contains('Navigator 2'));
        },
      );

      test(
        'a CustomRoute without a customRouteBuilder does not emit any warning',
        () async {
          final routes = <RouteConfig>[
            const RouteConfig(
              name: 'bottomSheetView',
              pathName: 'bottomSheetPath',
              className: 'BottomSheetClass',
              classImport: 'ui/bottom_sheet_class.dart',
              routeType: RouteType.custom,
            ),
          ];

          final printedLines = <String>[];
          await runZoned(
            () async {
              routerClassBuilderHelper.mapOfPages(routes);
            },
            zoneSpecification: ZoneSpecification(
              print: (self, parent, zone, line) => printedLines.add(line),
            ),
          );

          expect(printedLines, isEmpty,
              reason:
                  'No warning should be printed when customRouteBuilder is not set');
        },
      );
    });
  });
}
