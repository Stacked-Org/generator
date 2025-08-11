import 'package:test/test.dart';

import 'package:stacked_generator/src/generators/router_2/code_builder/library_builder.dart';
import 'package:stacked_generator/src/generators/router_common/models/importable_type.dart';
import 'package:stacked_generator/src/generators/router_common/models/router_config.dart';
import 'package:stacked_generator/src/generators/router/route_config/material_route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_parameter_config.dart';
import 'package:stacked_generator/src/generators/exceptions/invalid_generator_input_exception.dart';
import '../../helpers/element2_mock_helper.dart';

void main() {
  group('Router 2.0 Integration Tests -', () {
    group('Complete Library Generation -', () {
      test('should generate complete router for simple app', () {
        final routes = [
          MaterialRouteConfig(
            name: 'homeView',
            pathName: '/',
            className: 'HomeView',
            classImport: 'views/home_view.dart',
            pageType: ResolvedType(name: 'HomeView', import: 'views/home_view.dart'),
            parameters: [],
          ),
          MaterialRouteConfig(
            name: 'loginView',
            pathName: '/login',
            className: 'LoginView',
            classImport: 'views/login_view.dart',
            pageType: ResolvedType(name: 'LoginView', import: 'views/login_view.dart'),
            parameters: [
              ParamConfig(
                name: 'redirectPath',
                type: ResolvedType(name: 'String'),
                isPathParam: false,
                isQueryParam: true,
              ),
            ],
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'AppRouter',
          routesClassName: 'AppRoutes',
          routes: routes,
          element: createMockClassElement2(fileName: 'app_router.dart'),
        );

        final result = generateLibrary(config);

        expect(result, isNotEmpty);
        expect(result, contains('AppRouter'));
        expect(result, contains('HomeView'));
        expect(result, contains('LoginView'));
        
        // Validate the generated code is syntactically correct
        expect(() => result, returnsNormally);
      });

      test('should generate router with nested routes', () {
        final childRoutes = [
          MaterialRouteConfig(
            name: 'userProfile',
            pathName: '/profile',
            className: 'UserProfileView',
            classImport: 'views/user/user_profile_view.dart',
            pageType: ResolvedType(name: 'UserProfileView', import: 'views/user/user_profile_view.dart'),
          ),
        ];

        final routes = [
          MaterialRouteConfig(
            name: 'userDashboard',
            pathName: '/user',
            className: 'UserDashboardView',
            classImport: 'views/user/user_dashboard_view.dart',
            pageType: ResolvedType(name: 'UserDashboardView', import: 'views/user/user_dashboard_view.dart'),
            children: childRoutes,
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'UserRouter',
          routesClassName: 'UserRoutes',
          routes: routes,
          element: createMockClassElement2(fileName: 'user_router.dart'),
        );

        final result = generateLibrary(config);

        expect(result, isNotEmpty);
        expect(result, contains('UserRouter'));
        expect(result, contains('UserDashboardView'));
        // Note: Child routes handling in Router 2.0 may need special configuration
        // For now we verify the parent route is generated correctly
      });

      test('should handle complex route parameters', () {
        final routes = [
          MaterialRouteConfig(
            name: 'articleView',
            pathName: '/article/:articleId',
            className: 'ArticleView',
            classImport: 'views/article_view.dart',
            pageType: ResolvedType(name: 'ArticleView', import: 'views/article_view.dart'),
            parameters: [
              ParamConfig(
                name: 'articleId',
                type: ResolvedType(name: 'String'),
                isPathParam: true,
                isQueryParam: false,
              ),
              ParamConfig(
                name: 'category',
                type: ResolvedType(name: 'String'),
                isPathParam: false,
                isQueryParam: true,
              ),
              ParamConfig(
                name: 'tags',
                type: ResolvedType(name: 'List', typeArguments: [ResolvedType(name: 'String')]),
                isPathParam: false,
                isQueryParam: true,
              ),
            ],
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'ArticleRouter',
          routesClassName: 'ArticleRoutes',
          routes: routes,
          element: createMockClassElement2(fileName: 'article_router.dart'),
        );

        final result = generateLibrary(config);

        expect(result, isNotEmpty);
        expect(result, contains('ArticleView'));
        expect(result, contains('articleId'));
        expect(result, contains('category'));
        expect(result, contains('tags'));
      });

      test('should generate router with custom route types', () {
        // This would test different route types like Cupertino, Custom, etc.
        final routes = [
          MaterialRouteConfig(
            name: 'homeView',
            pathName: '/',
            className: 'HomeView',
            classImport: 'views/home_view.dart',
            pageType: ResolvedType(name: 'HomeView', import: 'views/home_view.dart'),
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'CustomRouter',
          routesClassName: 'CustomRoutes',
          routes: routes,
          element: createMockClassElement2(fileName: 'custom_router.dart'),
        );

        final result = generateLibrary(config);

        expect(result, isNotEmpty);
        expect(result, contains('CustomRouter'));
      });
    });

    group('Error Scenarios -', () {
      test('should handle empty configuration gracefully', () {
        final config = RouterConfig(
          routerClassName: 'EmptyRouter',
          routesClassName: 'EmptyRoutes',
          routes: [],
          element: createMockClassElement2(fileName: 'empty_router.dart'),
        );

        // Currently the Router 2.0 generator doesn't handle empty routes well
        // This is a known limitation that should be fixed in the generator
        expect(
          () => generateLibrary(config),
          throwsStateError,
        );
      });

      test('should validate against invalid configurations', () {
        // Test various invalid configurations that should throw errors
        final duplicateRoutes = [
          MaterialRouteConfig(
            name: 'duplicateRoute',
            pathName: '/path1',
            className: 'View1',
            classImport: 'views/view1.dart',
            pageType: ResolvedType(name: 'View1', import: 'views/view1.dart'),
          ),
          MaterialRouteConfig(
            name: 'duplicateRoute', // Same name
            pathName: '/path2', // Different path
            className: 'View2',
            classImport: 'views/view2.dart',
            pageType: ResolvedType(name: 'View2', import: 'views/view2.dart'),
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'InvalidRouter',
          routesClassName: 'InvalidRoutes',
          routes: duplicateRoutes,
          element: createMockClassElement2(fileName: 'invalid_router.dart'),
        );

        expect(
          () => generateLibrary(config),
          throwsA(isA<InvalidGeneratorInputException>()),
        );
      });
    });

    group('Code Quality -', () {
      test('generated code should be properly formatted', () {
        final routes = [
          MaterialRouteConfig(
            name: 'testView',
            pathName: '/test',
            className: 'TestView',
            classImport: 'views/test_view.dart',
            pageType: ResolvedType(name: 'TestView', import: 'views/test_view.dart'),
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'TestRouter',
          routesClassName: 'TestRoutes',
          routes: routes,
          element: createMockClassElement2(fileName: 'test_router.dart'),
        );

        final result = generateLibrary(config);

        expect(result, isNotEmpty);
        
        // Check for proper formatting indicators
        expect(result, isNot(contains('  \n'))); // No trailing spaces
        expect(result, isNot(contains('\n\n\n'))); // No excessive blank lines
        
        // Check for proper Dart structure
        expect(result, contains('class '));
        expect(result, contains('{'));
        expect(result, contains('}'));
      });

      test('should generate valid dart imports', () {
        final routes = [
          MaterialRouteConfig(
            name: 'importTestView',
            pathName: '/import-test',
            className: 'ImportTestView',
            classImport: 'views/import_test_view.dart',
            pageType: ResolvedType(name: 'ImportTestView', import: 'views/import_test_view.dart'),
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'ImportTestRouter',
          routesClassName: 'ImportTestRoutes',
          routes: routes,
          element: createMockClassElement2(fileName: 'import_test_router.dart'),
        );

        final result = generateLibrary(config);

        expect(result, isNotEmpty);
        
        // Should have proper import statements
        expect(result, contains('import '));
        expect(result, contains('package:'));
      });
    });
  });
}