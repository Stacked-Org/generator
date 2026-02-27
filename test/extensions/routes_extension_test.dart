import 'package:stacked_generator/src/generators/extensions/routes_extension.dart';
import 'package:stacked_generator/src/generators/router_common/models/router_config.dart';
import 'package:stacked_generator/src/generators/router/route_config/material_route_config.dart';
import 'package:test/test.dart';

void main() {
  group('RoutesExtension -', () {
    group('traverseRoutes -', () {
      test('should call action on single router config with no children', () {
        final routes = [
          MaterialRouteConfig(
            name: 'home',
            pathName: '/home',
            className: 'HomeView',
            classImport: 'views/home_view.dart',
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'AppRouter',
          routesClassName: 'AppRoutes', 
          routes: routes,
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(1));
        expect(visitedConfigs.first.routerClassName, equals('AppRouter'));
      });

      test('should traverse routes with children recursively', () {
        final childRoutes = [
          MaterialRouteConfig(
            name: 'userProfile',
            pathName: '/profile',
            className: 'UserProfileView',
            classImport: 'views/user_profile_view.dart',
          ),
        ];

        final parentRoutes = [
          MaterialRouteConfig(
            name: 'user',
            pathName: '/user',
            className: 'UserView',
            classImport: 'views/user_view.dart',
            children: childRoutes,
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'AppRouter',
          routesClassName: 'AppRoutes',
          routes: parentRoutes,
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(2));
        expect(visitedConfigs[0].routerClassName, equals('AppRouter'));
        expect(visitedConfigs[1].routerClassName, equals('UserRouter')); // Generated from route name
        expect(visitedConfigs[1].routesClassName, equals('UserRoutes'));
      });

      test('should generate correct router names from route names', () {
        final childRoutes = [
          MaterialRouteConfig(
            name: 'profileSettings',
            pathName: '/settings',
            className: 'ProfileSettingsView',
            classImport: 'views/profile_settings_view.dart',
          ),
        ];

        final routes = [
          MaterialRouteConfig(
            name: 'userDashboard',
            pathName: '/dashboard',
            className: 'UserDashboardView',
            classImport: 'views/user_dashboard_view.dart',
            children: childRoutes,
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'MainRouter',
          routesClassName: 'MainRoutes',
          routes: routes,
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(2));
        expect(visitedConfigs[0].routerClassName, equals('MainRouter'));
        expect(visitedConfigs[1].routerClassName, equals('UserDashboardRouter')); // From 'userDashboard' + 'Router'
        expect(visitedConfigs[1].routesClassName, equals('UserDashboardRoutes'));
      });

      test('should handle multiple levels of nesting', () {
        final grandChildRoutes = [
          MaterialRouteConfig(
            name: 'deepSetting',
            pathName: '/deep',
            className: 'DeepSettingView',
            classImport: 'views/deep_setting_view.dart',
          ),
        ];

        final childRoutes = [
          MaterialRouteConfig(
            name: 'settings',
            pathName: '/settings',
            className: 'SettingsView',
            classImport: 'views/settings_view.dart',
            children: grandChildRoutes,
          ),
        ];

        final parentRoutes = [
          MaterialRouteConfig(
            name: 'admin',
            pathName: '/admin',
            className: 'AdminView',
            classImport: 'views/admin_view.dart',
            children: childRoutes,
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'AppRouter',
          routesClassName: 'AppRoutes',
          routes: parentRoutes,
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(3));
        expect(visitedConfigs[0].routerClassName, equals('AppRouter'));
        expect(visitedConfigs[1].routerClassName, equals('AdminRouter'));
        expect(visitedConfigs[2].routerClassName, equals('SettingsRouter'));
      });

      test('should handle multiple routes at the same level with children', () {
        final userChildRoutes = [
          MaterialRouteConfig(
            name: 'userProfile',
            pathName: '/profile',
            className: 'UserProfileView',
            classImport: 'views/user_profile_view.dart',
          ),
        ];

        final adminChildRoutes = [
          MaterialRouteConfig(
            name: 'adminSettings',
            pathName: '/settings',
            className: 'AdminSettingsView',
            classImport: 'views/admin_settings_view.dart',
          ),
        ];

        final routes = [
          MaterialRouteConfig(
            name: 'user',
            pathName: '/user',
            className: 'UserView',
            classImport: 'views/user_view.dart',
            children: userChildRoutes,
          ),
          MaterialRouteConfig(
            name: 'admin',
            pathName: '/admin',
            className: 'AdminView',
            classImport: 'views/admin_view.dart',
            children: adminChildRoutes,
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'AppRouter',
          routesClassName: 'AppRoutes',
          routes: routes,
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(3));
        expect(visitedConfigs[0].routerClassName, equals('AppRouter'));
        
        final childRouterNames = visitedConfigs.skip(1).map((c) => c.routerClassName).toSet();
        expect(childRouterNames, containsAll(['UserRouter', 'AdminRouter']));
      });

      test('should handle empty routes list', () {
        final config = RouterConfig(
          routerClassName: 'EmptyRouter',
          routesClassName: 'EmptyRoutes',
          routes: [],
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(1));
        expect(visitedConfigs.first.routerClassName, equals('EmptyRouter'));
      });

      test('should call action with correct route data at each level', () {
        final childRoute = MaterialRouteConfig(
          name: 'child',
          pathName: '/child',
          className: 'ChildView',
          classImport: 'views/child_view.dart',
        );

        final parentRoute = MaterialRouteConfig(
          name: 'parent',
          pathName: '/parent',
          className: 'ParentView',
          classImport: 'views/parent_view.dart',
          children: [childRoute],
        );

        final config = RouterConfig(
          routerClassName: 'RootRouter',
          routesClassName: 'RootRoutes',
          routes: [parentRoute],
        );

        final routeInfos = <String>[];
        config.traverseRoutes((routerConfig) {
          routeInfos.add('${routerConfig.routerClassName}:${routerConfig.routes.length}');
        });

        expect(routeInfos.length, equals(2));
        expect(routeInfos[0], equals('RootRouter:1')); // Root has 1 parent route
        expect(routeInfos[1], equals('ParentRouter:1')); // Parent router has 1 child route
      });

      test('should capitalize route names correctly for router class names', () {
        final routes = [
          MaterialRouteConfig(
            name: 'lowerCase',
            pathName: '/lower',
            className: 'LowerView',
            classImport: 'views/lower_view.dart',
            children: [
              MaterialRouteConfig(
                name: 'child',
                pathName: '/child',
                className: 'ChildView',
                classImport: 'views/child_view.dart',
              ),
            ],
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'MainRouter',
          routesClassName: 'MainRoutes',
          routes: routes,
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(2));
        expect(visitedConfigs[1].routerClassName, equals('LowerCaseRouter')); // Capitalized
        expect(visitedConfigs[1].routesClassName, equals('LowerCaseRoutes'));
      });
    });

    group('Edge Cases -', () {
      test('should handle routes with complex names containing numbers and symbols', () {
        final routes = [
          MaterialRouteConfig(
            name: 'user123_admin',
            pathName: '/user123',
            className: 'User123View',
            classImport: 'views/user123_view.dart',
            children: [
              MaterialRouteConfig(
                name: 'settings2',
                pathName: '/settings2',
                className: 'Settings2View',
                classImport: 'views/settings2_view.dart',
              ),
            ],
          ),
        ];

        final config = RouterConfig(
          routerClassName: 'TestRouter',
          routesClassName: 'TestRoutes',
          routes: routes,
        );

        final visitedConfigs = <RouterConfig>[];
        config.traverseRoutes((routerConfig) {
          visitedConfigs.add(routerConfig);
        });

        expect(visitedConfigs.length, equals(2));
        expect(visitedConfigs[1].routerClassName, equals('User123_adminRouter'));
      });

      test('should maintain immutability of original config', () {
        final routes = [
          MaterialRouteConfig(
            name: 'test',
            pathName: '/test',
            className: 'TestView',
            classImport: 'views/test_view.dart',
          ),
        ];

        final originalConfig = RouterConfig(
          routerClassName: 'OriginalRouter',
          routesClassName: 'OriginalRoutes',
          routes: routes,
        );

        final originalRouterClassName = originalConfig.routerClassName;
        final originalRoutesClassName = originalConfig.routesClassName;
        final originalRoutesLength = originalConfig.routes.length;

        originalConfig.traverseRoutes((routerConfig) {
          // Modify the visited config (should not affect original)
          // Note: RouterConfig is immutable, but this test ensures the traversal doesn't modify anything
        });

        expect(originalConfig.routerClassName, equals(originalRouterClassName));
        expect(originalConfig.routesClassName, equals(originalRoutesClassName));
        expect(originalConfig.routes.length, equals(originalRoutesLength));
      });
    });
  });
}