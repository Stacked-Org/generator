import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// AST validators for router code generation.
/// Provide semantic checks for router classes, helpers, and complete systems.
/// Use structure-aware (AST) validation to avoid brittle string comparisons.

/// Basic router class validation: inheritance, fields, and getters.
class RouterAstValidator {
  /// Validate the overall structure: class name, superclass, fields, getters.
  static void validateRouterClassStructure(
    String generatedCode, {
    required String expectedClassName,
    required String expectedSuperclass,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // Find the router class
    final routerClass = AstHelper.findClass(unit, expectedClassName);
    expect(routerClass, isNotNull,
        reason: 'Should contain class $expectedClassName');

    // Validate superclass
    final superclass = AstHelper.getSuperclassName(routerClass!);
    expect(superclass, contains(expectedSuperclass),
        reason: 'Class should extend $expectedSuperclass');

    // Validate required fields exist
    final routesField = AstHelper.findField(routerClass, '_routes');
    expect(routesField, isNotNull, reason: 'Should have _routes field');

    final pagesMapField = AstHelper.findField(routerClass, '_pagesMap');
    expect(pagesMapField, isNotNull, reason: 'Should have _pagesMap field');

    // Validate override methods exist
    final routesGetter = AstHelper.findMethod(routerClass, 'routes');
    expect(routesGetter, isNotNull, reason: 'Should have routes getter');
    expect(AstHelper.hasOverrideAnnotation(routesGetter!), isTrue,
        reason: 'routes getter should have @override annotation');

    final pagesMapGetter = AstHelper.findMethod(routerClass, 'pagesMap');
    expect(pagesMapGetter, isNotNull, reason: 'Should have pagesMap getter');
    expect(AstHelper.hasOverrideAnnotation(pagesMapGetter!), isTrue,
        reason: 'pagesMap getter should have @override annotation');
  }

  /// Ensure generated code contains the required imports by URI.
  static void validateRequiredImports(
    String generatedCode, {
    required List<String> requiredImports,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    for (final importUri in requiredImports) {
      expect(AstHelper.hasImport(unit, importUri), isTrue,
          reason: 'Should import $importUri');
    }
  }

  /// Ensure _routes field exists, is final, and typed as List<RouteDef>.
  static void validateRoutesField(
    String generatedCode, {
    required int expectedRouteCount,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    final routerClass = unit.declarations.whereType<ClassDeclaration>().first;

    final routesField = AstHelper.findField(routerClass, '_routes');
    expect(routesField, isNotNull);

    // Validate field is final and has correct type
    expect(AstHelper.isFieldFinal(routesField!), isTrue,
        reason: '_routes field should be final');

    final fieldType = AstHelper.getFieldType(routesField);
    expect(fieldType, contains('RouteDef'),
        reason: '_routes should be List<RouteDef>');
  }

  /// Ensure _pagesMap field exists, is final, and typed with StackedRouteFactory.
  static void validatePagesMapField(
    String generatedCode, {
    required int expectedPageCount,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    final routerClass = unit.declarations.whereType<ClassDeclaration>().first;

    final pagesMapField = AstHelper.findField(routerClass, '_pagesMap');
    expect(pagesMapField, isNotNull);

    // Validate field is final and has correct type
    expect(AstHelper.isFieldFinal(pagesMapField!), isTrue,
        reason: '_pagesMap field should be final');

    final fieldType = AstHelper.getFieldType(pagesMapField);
    expect(fieldType, contains('StackedRouteFactory'),
        reason: '_pagesMap should be Map<Type, StackedRouteFactory>');
  }

  /// Ensure routes/pagesMap getters exist and return correct types.
  static void validateGetterMethods(String generatedCode) {
    final unit = AstHelper.parseCode(generatedCode);
    final routerClass = unit.declarations.whereType<ClassDeclaration>().first;

    final routesGetter = AstHelper.findMethod(routerClass, 'routes');
    expect(routesGetter, isNotNull);

    final routesReturnType = AstHelper.getMethodReturnType(routesGetter!);
    expect(routesReturnType, contains('RouteDef'),
        reason: 'routes getter should return List<RouteDef>');

    final pagesMapGetter = AstHelper.findMethod(routerClass, 'pagesMap');
    expect(pagesMapGetter, isNotNull);

    final pagesMapReturnType = AstHelper.getMethodReturnType(pagesMapGetter!);
    expect(pagesMapReturnType, contains('StackedRouteFactory'),
        reason: 'pagesMap getter should return Map<Type, StackedRouteFactory>');
  }
}

/// Validation helpers for standalone route definitions and utilities.
class RouterHelperAstValidator {
  /// Validate a standalone _routes list: final and List<RouteDef> typed.
  static void validateRouteDefList(
    String generatedCode, {
    required int expectedRouteCount,
    required String routesClassName,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // Should have a variable declaration for _routes
    final variables =
        unit.declarations.whereType<TopLevelVariableDeclaration>();
    expect(variables, isNotEmpty, reason: 'Should contain route list variable');

    final routesVar = variables.first;
    final variableName = AstHelper.getVariableNames(routesVar.variables).first;
    expect(variableName, equals('_routes'),
        reason: 'Variable should be named _routes');

    // Should be final
    expect(AstHelper.isVariableFinal(routesVar.variables), isTrue,
        reason: '_routes should be final');

    // Should contain RouteDef in type
    final fieldType = AstHelper.getVariableType(routesVar.variables);
    expect(fieldType, contains('RouteDef'),
        reason: 'Should be List of RouteDef');
  }

  /// Validate a getter method (class or top-level) by name and return type.
  static void validateGetterMethod(
    String generatedCode, {
    required String methodName,
    required String expectedReturnType,
    required bool shouldHaveOverride,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // Find method in top-level declarations or in a class
    String? returnType;
    bool hasOverride = false;

    // Check if it's a class method
    final classes = unit.declarations.whereType<ClassDeclaration>();
    if (classes.isNotEmpty) {
      final method = AstHelper.findMethod(classes.first, methodName);
      expect(method, isNotNull, reason: 'Should contain $methodName method');
      returnType = AstHelper.getMethodReturnType(method!);
      hasOverride = AstHelper.hasOverrideAnnotation(method);
    } else {
      // Check if it's a top-level function
      final functions = unit.declarations.whereType<FunctionDeclaration>();
      final function =
          functions.where((f) => f.name.lexeme == methodName).firstOrNull;
      expect(function, isNotNull,
          reason: 'Should contain $methodName function');
      returnType = function!.returnType?.toString();
      // Functions don't have override annotations
    }

    if (shouldHaveOverride) {
      expect(hasOverride, isTrue,
          reason: '$methodName should have @override annotation');
    }

    expect(returnType, contains(expectedReturnType),
        reason: '$methodName should return $expectedReturnType');
  }

  /// Validate a map structure variable: name, final, key/value types.
  static void validateMapStructure(
    String generatedCode, {
    required String mapName,
    required String keyType,
    required String valueType,
    required int expectedEntryCount,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // Find the map variable
    final variables =
        unit.declarations.whereType<TopLevelVariableDeclaration>();
    expect(variables, isNotEmpty, reason: 'Should contain map variable');

    final mapVar = variables.first;
    final variableName = AstHelper.getVariableNames(mapVar.variables).first;
    expect(variableName, equals(mapName),
        reason: 'Variable should be named $mapName');

    // Should be final
    expect(AstHelper.isVariableFinal(mapVar.variables), isTrue,
        reason: '$mapName should be final');

    // Check type contains expected key and value types
    final fieldType = AstHelper.getVariableType(mapVar.variables);
    expect(fieldType, contains(keyType),
        reason: 'Should contain $keyType in map type');
    expect(fieldType, contains(valueType),
        reason: 'Should contain $valueType in map type');
  }

  /// Ensure imports exist and are aliased where expected (e.g., `as _i`).
  static void validateHelperImports(
    String generatedCode, {
    required List<String> expectedImports,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    for (final importUri in expectedImports) {
      expect(AstHelper.hasImport(unit, importUri), isTrue,
          reason: 'Should import $importUri');
    }

    // Validate that imports are aliased (should contain ' as _i')
    final imports = AstHelper.getImports(unit);
    final aliasedImports = imports.where((i) => i.prefix != null);
    expect(aliasedImports, isNotEmpty,
        reason: 'Should have aliased imports for avoiding conflicts');
  }
}

/// Validators for complete router generation scenarios (simple, nested, mixed).
/// Covers routes class, router class, navigation extension, and arguments.
class RouteClassGeneratorAstValidator {
  /// Validate a complete router output (routes, router, extension, args).
  static void validateCompleteRouterGeneration(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required List<RouteConfig> expectedRoutes,
    bool shouldHaveNavigationExtension = true,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate all components exist
    _validateRoutesClassExists(unit, routesClassName, expectedRoutes);
    _validateRouterClassExists(unit, routerClassName);

    if (shouldHaveNavigationExtension) {
      _validateNavigationExtensionExists(unit, expectedRoutes);
    }

    // Validate argument classes for routes with parameters
    _validateArgumentClassesExist(unit, expectedRoutes);
  }

  /// Validate a simple single-route router (convenience wrapper).
  static void validateBasicRouterGeneration(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required RouteConfig expectedRoute,
  }) {
    validateCompleteRouterGeneration(
      generatedCode,
      routerClassName: routerClassName,
      routesClassName: routesClassName,
      expectedRoutes: [expectedRoute],
      shouldHaveNavigationExtension: true,
    );
  }

  /// Validate nested routers (parent with child routes and nested classes).
  static void validateNestedRouterGeneration(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required RouteConfig parentRoute,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate main router components
    _validateRoutesClassExists(unit, routesClassName, [parentRoute]);
    _validateRouterClassExists(unit, routerClassName);

    // If parent has children, validate nested router classes
    if (parentRoute.children.isNotEmpty) {
      final parentName = parentRoute.name ?? 'unknown';
      final nestedRouterClassName = '${_capitalize(parentName)}Router';
      final nestedRoutesClassName = '${_capitalize(parentName)}Routes';

      _validateRoutesClassExists(
          unit, nestedRoutesClassName, parentRoute.children);
      _validateRouterClassExists(unit, nestedRouterClassName);
    }

    _validateNavigationExtensionExists(unit, [parentRoute]);
  }

  /// Validate router with aliased imports and parameterized routes.
  static void validateRouterWithAliasedImports(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required RouteConfig routeWithParameters,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Basic structure validation
    _validateRoutesClassExists(unit, routesClassName, [routeWithParameters]);
    _validateRouterClassExists(unit, routerClassName);
    _validateNavigationExtensionExists(unit, [routeWithParameters]);

    // Validate PageRouteBuilder usage for custom routes
    final routerClass = AstHelper.findClass(unit, routerClassName);
    expect(routerClass, isNotNull, reason: 'Router class should exist');

    // Validate argument class for parameters
    if (routeWithParameters.parameters.isNotEmpty) {
      final argumentsClassName = '${routeWithParameters.className}Arguments';
      final argumentsClass = AstHelper.findClass(unit, argumentsClassName);
      expect(argumentsClass, isNotNull,
          reason: 'Arguments class should exist for route with parameters');
    }
  }

  /// Validate mixed routing systems containing multiple route types.
  static void validateMixedRoutingSystem(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required List<RouteConfig> mixedRoutes,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate basic structure
    _validateRoutesClassExists(unit, routesClassName, mixedRoutes);
    _validateRouterClassExists(unit, routerClassName);
    _validateNavigationExtensionExists(unit, mixedRoutes);

    // Validate argument classes for routes with parameters
    _validateArgumentClassesExist(unit, mixedRoutes);

    // Ensure all route types are properly handled
    final routerClass = AstHelper.findClass(unit, routerClassName);
    expect(routerClass, isNotNull, reason: 'Router class should exist');

    final pagesMapField = AstHelper.findField(routerClass!, '_pagesMap');
    expect(pagesMapField, isNotNull,
        reason: 'Router should have _pagesMap field');
  }

  // Private helper methods

  /// Ensure routes class exists and exposes route constants and `all`.
  static void _validateRoutesClassExists(
    CompilationUnit unit,
    String routesClassName,
    List<RouteConfig> expectedRoutes,
  ) {
    final routesClass = AstHelper.findClass(unit, routesClassName);
    expect(routesClass, isNotNull,
        reason: 'Routes class $routesClassName should exist');

    // Validate route constants
    for (final route in expectedRoutes) {
      final routeName = route.name ?? 'unknown';
      final field = AstHelper.findField(routesClass!, routeName);
      expect(field, isNotNull,
          reason:
              'Route $routeName should have a constant in $routesClassName');
    }

    // Validate 'all' field
    final allField = AstHelper.findField(routesClass!, 'all');
    expect(allField, isNotNull,
        reason: '$routesClassName should have an "all" field');
  }

  /// Ensure router class exists, extends RouterBase, has fields/getters.
  static void _validateRouterClassExists(
    CompilationUnit unit,
    String routerClassName,
  ) {
    final routerClass = AstHelper.findClass(unit, routerClassName);
    expect(routerClass, isNotNull,
        reason: 'Router class $routerClassName should exist');

    // Check inheritance
    expect(routerClass!.extendsClause?.superclass.name2.lexeme,
        contains('RouterBase'),
        reason: '$routerClassName should extend RouterBase');

    // Check required fields
    expect(AstHelper.findField(routerClass, '_routes'), isNotNull,
        reason: '$routerClassName should have _routes field');
    expect(AstHelper.findField(routerClass, '_pagesMap'), isNotNull,
        reason: '$routerClassName should have _pagesMap field');

    // Check required getters
    expect(AstHelper.findMethod(routerClass, 'routes'), isNotNull,
        reason: '$routerClassName should have routes getter');
    expect(AstHelper.findMethod(routerClass, 'pagesMap'), isNotNull,
        reason: '$routerClassName should have pagesMap getter');
  }

  /// Ensure navigation extension exists with navigateTo/replaceWith methods.
  static void _validateNavigationExtensionExists(
    CompilationUnit unit,
    List<RouteConfig> expectedRoutes,
  ) {
    bool extensionFound = false;

    for (final declaration in unit.declarations) {
      if (declaration is ExtensionDeclaration &&
          declaration.name?.lexeme == 'NavigatorStateExtension') {
        extensionFound = true;

        // Check navigation methods exist for each route
        for (final route in expectedRoutes) {
          final routeName = route.name ?? 'unknown';
          final navigateName = 'navigateTo${_capitalize(routeName)}';
          final replaceName = 'replaceWith${_capitalize(routeName)}';

          final navigateMethod =
              AstHelper.findMethodInExtension(declaration, navigateName);
          final replaceMethod =
              AstHelper.findMethodInExtension(declaration, replaceName);

          expect(navigateMethod, isNotNull,
              reason: 'Extension should have $navigateName method');
          expect(replaceMethod, isNotNull,
              reason: 'Extension should have $replaceName method');
        }
        break;
      }
    }

    expect(extensionFound, isTrue,
        reason: 'NavigatorStateExtension should exist');
  }

  /// Ensure argument classes exist for routes with non-query parameters.
  static void _validateArgumentClassesExist(
    CompilationUnit unit,
    List<RouteConfig> expectedRoutes,
  ) {
    for (final route in expectedRoutes) {
      // Only validate argument classes for routes with non-query parameters
      final nonQueryParams =
          route.parameters.where((p) => !p.isQueryParam).toList();

      if (nonQueryParams.isNotEmpty) {
        final argumentsClassName = '${route.className}Arguments';
        final argumentsClass = AstHelper.findClass(unit, argumentsClassName);

        expect(argumentsClass, isNotNull,
            reason: 'Arguments class $argumentsClassName should exist');

        if (argumentsClass != null) {
          // Validate constructor exists
          final constructor =
              AstHelper.findConstructor(argumentsClass, argumentsClassName);
          expect(constructor, isNotNull,
              reason: '$argumentsClassName should have a constructor');

          // Validate parameter fields exist for non-query params
          for (final param in nonQueryParams) {
            final field = AstHelper.findField(argumentsClass, param.name);
            expect(field, isNotNull,
                reason: '$argumentsClassName should have field ${param.name}');
          }

          // Validate toString method exists
          final toStringMethod =
              AstHelper.findMethod(argumentsClass, 'toString');
          expect(toStringMethod, isNotNull,
              reason: '$argumentsClassName should have toString method');
        }
      }
    }
  }

  /// Capitalize the first letter of a string.
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
