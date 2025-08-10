import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_parameter_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// AST validators for router code generation.
/// Provide semantic checks for router classes, helpers, and complete systems.
/// Use structure-aware (AST) validation to avoid brittle string comparisons.

/// Router 2.0 library builder validation
class LibraryBuilderAstValidator {
  /// Validate the generated library structure for Router 2.0
  static void validateGeneratedLibrary(
    String generatedCode, {
    required dynamic expectedConfig,
    required bool usesPartBuilder,
    required bool deferredLoading,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate part directive if using part builder
    if (usesPartBuilder) {
      validatePartDirective(generatedCode, expectedFileName: 'test.gr.dart');
    }

    // Validate router configuration is generated
    final routerConfig = AstHelper.findTopLevelVariableDeclaration(unit, 'router');
    expect(routerConfig, isNotNull, reason: 'Should contain router configuration');
  }

  /// Validate part directive generation
  static void validatePartDirective(String generatedCode, {required String expectedFileName}) {
    expect(generatedCode, contains('part of'), reason: 'Should contain part of directive');
  }
}

/// Router extension validation for Router 2.0
class RouterExtensionAstValidator {
  /// Validate router extension generation
  static void validateRouterExtension(String generatedCode, {required List<RouteConfig> expectedRoutes}) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Look for extension on router service
    final extensions = AstHelper.findExtensions(unit);
    expect(extensions, isNotEmpty, reason: 'Should contain router extensions');
  }
}

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

  /// Ensure _routes field exists, is final, and typed as List`<RouteDef>`.
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
  /// Validate a standalone _routes list: final and List`<RouteDef>` typed.
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

/// Arguments Class-specific validation functions for argument class generation.
///
/// This validator focuses on the generation of argument classes for routes
/// that have parameters, including constructor validation, property validation,
/// and standard method implementations (toString, ==, hashCode).
class ArgumentsClassAstValidator {
  /// Validates argument classes generation for multiple routes.
  ///
  /// Checks that argument classes are generated correctly for routes with parameters,
  /// including proper constructor signatures, field declarations, and standard methods.
  ///
  /// Example:
  /// ```dart
  /// ArgumentsClassAstValidator.validateArgumentClasses(
  ///   generatedCode,
  ///   expectedRoutes: routes,
  /// );
  /// ```
  static void validateArgumentClasses(
    String generatedCode, {
    required List<RouteConfig> expectedRoutes,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate imports for custom types
    _validateArgumentClassImports(unit, expectedRoutes);

    // Validate each route that has parameters
    for (final route in expectedRoutes) {
      final nonQueryParams = route.parameters.where((p) => !p.isQueryParam).toList();
      
      if (nonQueryParams.isNotEmpty) {
        final argumentsClassName = '${route.className}Arguments';
        _validateSingleArgumentClass(unit, argumentsClassName, nonQueryParams);
      }
    }
  }

  /// Validates a single argument class structure.
  ///
  /// Checks constructor, fields, and standard methods for a specific argument class.
  static void validateSingleArgumentClass(
    String generatedCode, {
    required String className,
    required List<ParamConfig> expectedParameters,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    _validateSingleArgumentClass(unit, className, expectedParameters);
  }

  // Private helper methods

  /// Validates imports for argument classes.
  static void _validateArgumentClassImports(CompilationUnit unit, List<RouteConfig> routes) {
    // Collect all imports needed for parameters
    final requiredImports = <String>{};
    for (final route in routes) {
      for (final param in route.parameters) {
        final import = param.type.import;
        if (import != null && import.isNotEmpty) {
          requiredImports.add(import);
        }
      }
    }

    // Validate each required import exists
    for (final importUri in requiredImports) {
      expect(AstHelper.hasImport(unit, importUri), isTrue,
          reason: 'Should import $importUri for parameter types');
    }
  }

  /// Validates a single argument class structure.
  static void _validateSingleArgumentClass(
    CompilationUnit unit, 
    String className, 
    List<ParamConfig> expectedParameters
  ) {
    // Find the argument class
    final argumentClass = AstHelper.findClass(unit, className);
    expect(argumentClass, isNotNull,
        reason: 'Argument class $className should exist');

    if (argumentClass != null) {
      // Validate constructor
      _validateArgumentClassConstructor(argumentClass, className, expectedParameters);
      
      // Validate fields
      _validateArgumentClassFields(argumentClass, expectedParameters);
      
      // Validate standard methods
      _validateArgumentClassMethods(argumentClass);
    }
  }

  /// Validates the constructor of an argument class.
  static void _validateArgumentClassConstructor(
    ClassDeclaration argumentClass, 
    String className, 
    List<ParamConfig> expectedParameters
  ) {
    final constructor = AstHelper.findConstructor(argumentClass, className);
    expect(constructor, isNotNull,
        reason: '$className should have a constructor');

    if (constructor != null) {
      // Should be const constructor
      expect(constructor.constKeyword, isNotNull,
          reason: '$className constructor should be const');

      // Validate constructor parameters match expected parameters
      final constructorParams = constructor.parameters.parameters;
      
      // Count required and optional parameters
      final requiredParams = expectedParameters.where((p) => p.isRequired).length;
      final optionalParams = expectedParameters.where((p) => !p.isRequired).length;
      
      expect(constructorParams.length, 
          equals(requiredParams + optionalParams),
          reason: '$className constructor should have ${expectedParameters.length} parameters');
    }
  }

  /// Validates fields of an argument class.
  static void _validateArgumentClassFields(
    ClassDeclaration argumentClass, 
    List<ParamConfig> expectedParameters
  ) {
    for (final param in expectedParameters) {
      final field = AstHelper.findField(argumentClass, param.name);
      expect(field, isNotNull,
          reason: 'Argument class should have field ${param.name}');

      if (field != null) {
        // Should be final
        expect(AstHelper.isFieldFinal(field), isTrue,
            reason: 'Field ${param.name} should be final');

        // Validate field type contains expected type name
        final fieldType = AstHelper.getFieldType(field);
        expect(fieldType, contains(param.type.name),
            reason: 'Field ${param.name} should have type ${param.type.name}');
      }
    }
  }

  /// Validates standard methods of an argument class.
  static void _validateArgumentClassMethods(ClassDeclaration argumentClass) {
    // Validate toString method
    final toStringMethod = AstHelper.findMethod(argumentClass, 'toString');
    expect(toStringMethod, isNotNull,
        reason: 'Argument class should have toString method');

    if (toStringMethod != null) {
      expect(AstHelper.hasOverrideAnnotation(toStringMethod), isTrue,
          reason: 'toString method should have @override annotation');
    }

    // Validate == operator method
    final equalsMethod = AstHelper.findMethod(argumentClass, '==');
    expect(equalsMethod, isNotNull,
        reason: 'Argument class should have == operator');

    if (equalsMethod != null) {
      expect(AstHelper.hasOverrideAnnotation(equalsMethod), isTrue,
          reason: '== operator should have @override annotation');
    }

    // Validate hashCode getter
    final hashCodeGetter = AstHelper.findMethod(argumentClass, 'hashCode');
    expect(hashCodeGetter, isNotNull,
        reason: 'Argument class should have hashCode getter');

    if (hashCodeGetter != null) {
      expect(AstHelper.hasOverrideAnnotation(hashCodeGetter), isTrue,
          reason: 'hashCode getter should have @override annotation');
    }
  }
}

/// Routes Class-specific validation functions for routes class generation.
///
/// This validator focuses on the generation of route constants classes,
/// including static const fields for each route, the 'all' field with
/// all route names, and dynamic path methods for parameterized routes.
class RoutesClassAstValidator {
  /// Validates routes class generation.
  ///
  /// Checks that the routes class contains the expected static constants,
  /// the 'all' field, and any necessary dynamic path methods.
  ///
  /// Example:
  /// ```dart
  /// RoutesClassAstValidator.validateRoutesClass(
  ///   generatedCode,
  ///   expectedClassName: 'RoutesTestClassName',
  ///   expectedRoutes: routes,
  /// );
  /// ```
  static void validateRoutesClass(
    String generatedCode, {
    required String expectedClassName,
    required List<RouteConfig> expectedRoutes,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Find the routes class
    final routesClass = AstHelper.findClass(unit, expectedClassName);
    expect(routesClass, isNotNull,
        reason: 'Routes class $expectedClassName should exist');

    if (routesClass != null) {
      // Validate static const fields for each route
      _validateRouteConstants(routesClass, expectedRoutes);
      
      // Validate 'all' field
      _validateAllField(routesClass, expectedRoutes);
      
      // Validate dynamic path methods for parameterized routes
      _validateDynamicPathMethods(routesClass, expectedRoutes);
    }
  }

  // Private helper methods

  /// Validates static const fields for each route.
  static void _validateRouteConstants(ClassDeclaration routesClass, List<RouteConfig> expectedRoutes) {
    for (final route in expectedRoutes) {
      final routeName = route.name ?? 'unknown';
      final field = AstHelper.findField(routesClass, routeName);
      
      expect(field, isNotNull,
          reason: 'Routes class should have constant for $routeName');

      if (field != null) {
        // Should be static
        expect(field.isStatic, isTrue,
            reason: 'Route constant $routeName should be static');
        
        // Should be const or final (check for const or final keywords)
        final isConstOrFinal = AstHelper.isFieldFinal(field) || 
                             field.fields.variables.first.toString().contains('const') ||
                             field.fields.keyword?.lexeme == 'const';
        expect(isConstOrFinal, isTrue,
            reason: 'Route constant $routeName should be const or final');

        // Should have String type or be inferred (type checking is optional for constants)
        final fieldType = AstHelper.getFieldType(field);
        if (fieldType != null) {
          expect(fieldType, anyOf(contains('String'), equals('')),
              reason: 'Route constant $routeName should be String type when explicitly typed');
        }
      }
    }
  }

  /// Validates the 'all' field that contains all route names.
  static void _validateAllField(ClassDeclaration routesClass, List<RouteConfig> expectedRoutes) {
    final allField = AstHelper.findField(routesClass, 'all');
    expect(allField, isNotNull,
        reason: 'Routes class should have an "all" field');

    if (allField != null) {
      // Should be static
      expect(allField.isStatic, isTrue,
          reason: '"all" field should be static');
      
      // Should be const or final (check for const or final keywords)
      final isConstOrFinal = AstHelper.isFieldFinal(allField) || 
                           allField.fields.variables.first.toString().contains('const') ||
                           allField.fields.keyword?.lexeme == 'const';
      expect(isConstOrFinal, isTrue,
          reason: '"all" field should be const or final');

      // Should have Set<String> type or be inferred
      final fieldType = AstHelper.getFieldType(allField);
      if (fieldType != null) {
        expect(fieldType, anyOf(contains('Set'), contains('String')),
            reason: '"all" field should be Set<String> type when explicitly typed');
      }
    }
  }

  /// Validates dynamic path methods for routes with path parameters.
  static void _validateDynamicPathMethods(ClassDeclaration routesClass, List<RouteConfig> expectedRoutes) {
    for (final route in expectedRoutes) {
      // Check if route has path parameters (contains :param in pathName)
      final pathName = route.pathName;
      if (pathName.contains(':')) {
        final routeName = route.name ?? 'unknown';
        final methodName = routeName;
        
        final method = AstHelper.findMethod(routesClass, methodName);
        expect(method, isNotNull,
            reason: 'Routes class should have dynamic path method for $routeName');

        if (method != null) {
          // Should be static
          expect(method.isStatic, isTrue,
              reason: 'Dynamic path method $methodName should be static');
          
          // Should return String
          final returnType = AstHelper.getMethodReturnType(method);
          expect(returnType, contains('String'),
              reason: 'Dynamic path method $methodName should return String');
          
          // Should have parameters for path variables
          final parameters = method.parameters?.parameters ?? [];
          expect(parameters, isNotEmpty,
              reason: 'Dynamic path method $methodName should have parameters for path variables');
        }
      }
    }
  }
}

/// Validator for navigation extension classes.
///
/// This validator focuses on navigation extensions that provide
/// strongly-typed navigation methods for route navigation.
class NavigationExtensionAstValidator {
  /// Validates navigation extension structure and methods.
  ///
  /// Checks for:
  /// - Extension declaration with correct name
  /// - Extension on NavigatorState
  /// - Navigation methods for each route
  /// - Proper parameter handling
  ///
  /// Example:
  /// ```dart
  /// NavigationExtensionAstValidator.validateNavigationExtension(
  ///   generatedCode,
  ///   expectedRoutes: routes,
  ///   extensionName: 'NavigatorStateExtension',
  /// );
  /// ```
  static void validateNavigationExtension(
    String generatedCode, {
    required List<RouteConfig> expectedRoutes,
    String extensionName = 'NavigatorStateExtension',
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Find the extension
    final extension = _findExtension(unit, extensionName);
    expect(extension, isNotNull,
        reason: 'Should contain extension $extensionName');

    if (extension != null) {
      // Validate navigation methods for each route
      _validateNavigationMethods(extension, expectedRoutes);
    }
  }

  // Private helper methods

  /// Finds an extension declaration by name.
  static ExtensionDeclaration? _findExtension(CompilationUnit unit, String name) {
    for (final declaration in unit.declarations) {
      if (declaration is ExtensionDeclaration &&
          declaration.name?.lexeme == name) {
        return declaration;
      }
    }
    return null;
  }

  /// Validates navigation methods for routes.
  static void _validateNavigationMethods(
    ExtensionDeclaration extension,
    List<RouteConfig> expectedRoutes,
  ) {
    for (final route in expectedRoutes) {
      final routeName = route.name ?? 'unknown';
      final methodName = 'navigateTo${_capitalize(routeName)}';
      
      final method = _findMethodInExtension(extension, methodName);
      expect(method, isNotNull,
          reason: 'Extension should have method $methodName for route $routeName');

      if (method != null) {
        // Validate method parameters match route parameters
        _validateMethodParameters(method, route, methodName);
      }
    }
  }

  /// Finds a method in an extension declaration.
  static MethodDeclaration? _findMethodInExtension(
    ExtensionDeclaration extension,
    String methodName,
  ) {
    for (final member in extension.members) {
      if (member is MethodDeclaration && member.name.lexeme == methodName) {
        return member;
      }
    }
    return null;
  }

  /// Validates method parameters against route parameters.
  static void _validateMethodParameters(
    MethodDeclaration method,
    RouteConfig route,
    String methodName,
  ) {
    final parameters = method.parameters?.parameters ?? [];
    final routeParameters = route.parameters;

    if (routeParameters.isNotEmpty) {
      // Should have some way to handle parameters (either direct params or arguments object)
      final methodSignature = method.toString();
      final hasParameterHandling = parameters.isNotEmpty ||
          methodSignature.contains('arguments') ||
          methodSignature.contains('Arguments');
      
      expect(hasParameterHandling, isTrue,
          reason: 'Method $methodName should handle route parameters somehow');
    }
  }

  /// Capitalizes the first letter of a string.
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
