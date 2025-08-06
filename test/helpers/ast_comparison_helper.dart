import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';
import 'package:test/test.dart';

/// Helper class for AST-based code comparison and validation
class AstHelper {
  /// Parses Dart code string into a CompilationUnit AST
  static CompilationUnit parseCode(String code) {
    final result = parseString(content: code);
    if (result.errors.isNotEmpty) {
      fail('Failed to parse code: ${result.errors.first}');
    }
    return result.unit;
  }

  /// Finds a class declaration by name in the compilation unit
  static ClassDeclaration? findClass(CompilationUnit unit, String className) {
    return unit.declarations
        .whereType<ClassDeclaration>()
        .where((c) => c.name.lexeme == className)
        .firstOrNull;
  }

  /// Finds all method declarations in a class
  static List<MethodDeclaration> findMethods(ClassDeclaration classDecl) {
    return classDecl.members.whereType<MethodDeclaration>().toList();
  }

  /// Finds all field declarations in a class
  static List<FieldDeclaration> findFields(ClassDeclaration classDecl) {
    return classDecl.members.whereType<FieldDeclaration>().toList();
  }

  /// Finds a specific method by name in a class
  static MethodDeclaration? findMethod(
      ClassDeclaration classDecl, String methodName) {
    return findMethods(classDecl)
        .where((m) => m.name.lexeme == methodName)
        .firstOrNull;
  }

  /// Finds a specific field by name in a class
  static FieldDeclaration? findField(
      ClassDeclaration classDecl, String fieldName) {
    return findFields(classDecl)
        .where((f) => f.fields.variables.any((v) => v.name.lexeme == fieldName))
        .firstOrNull;
  }

  /// Gets all import directives from the compilation unit
  static List<ImportDirective> getImports(CompilationUnit unit) {
    return unit.directives.whereType<ImportDirective>().toList();
  }

  /// Checks if a specific import exists (by URI)
  static bool hasImport(CompilationUnit unit, String importUri) {
    return getImports(unit)
        .any((import) => import.uri.stringValue == importUri);
  }

  /// Gets the superclass name of a class (if any)
  static String? getSuperclassName(ClassDeclaration classDecl) {
    final extendsClause = classDecl.extendsClause;
    if (extendsClause?.superclass != null) {
      return extendsClause!.superclass.toString();
    }
    return null;
  }

  /// Checks if a method has override annotation
  static bool hasOverrideAnnotation(MethodDeclaration method) {
    return method.metadata
        .any((annotation) => annotation.name.name == 'override');
  }

  /// Gets all variable names from a field declaration
  static List<String> getFieldVariableNames(FieldDeclaration field) {
    return field.fields.variables.map((v) => v.name.lexeme).toList();
  }

  /// Gets all variable names from a variable declaration list
  static List<String> getVariableNames(VariableDeclarationList variables) {
    return variables.variables.map((v) => v.name.lexeme).toList();
  }

  /// Gets the return type of a method as string
  static String? getMethodReturnType(MethodDeclaration method) {
    return method.returnType?.toString();
  }

  /// Checks if a field is final
  static bool isFieldFinal(FieldDeclaration field) {
    return field.fields.keyword?.lexeme == 'final';
  }

  /// Checks if a variable declaration list is final
  static bool isVariableFinal(VariableDeclarationList variables) {
    return variables.keyword?.lexeme == 'final';
  }

  /// Gets the type annotation of a field as string
  /// If no explicit type annotation, tries to infer from initializer
  static String? getFieldType(FieldDeclaration field) {
    return getVariableType(field.fields);
  }

  /// Gets the type annotation of a variable list as string
  /// If no explicit type annotation, tries to infer from initializer
  static String? getVariableType(VariableDeclarationList variables) {
    // Try explicit type annotation first
    if (variables.type != null) {
      return variables.type.toString();
    }

    // Try to get type from initializer if it's a typed literal
    final variable = variables.variables.first;
    if (variable.initializer != null) {
      final initializer = variable.initializer.toString();
      // Handle cases like <RouteDef>[] or <Type, StackedRouteFactory>{}
      if (initializer.contains('<') && initializer.contains('>')) {
        final typeMatch = RegExp(r'<([^>]+)>').firstMatch(initializer);
        if (typeMatch != null) {
          return typeMatch.group(1);
        }
      }
    }

    return null;
  }
}

/// Router-specific validation functions
class RouterAstValidator {
  /// Validates the overall structure of a generated router class
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

  /// Validates that expected imports are present
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

  /// Validates the _routes field structure
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

  /// Validates the _pagesMap field structure
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

  /// Validates getter methods return correct types
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

/// Router Helper-specific validation functions
class RouterHelperAstValidator {
  /// Validates a standalone list of RouteDef objects
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
    expect(fieldType, contains('RouteDef'), reason: 'Should be List<RouteDef>');
  }

  /// Validates a standalone getter method
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

  /// Validates a map structure (like _pagesMap)
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

  /// Validates that imports are present and properly aliased
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

  /// Validates pages map factory functions structure
  static void validatePagesMapFactories(
    String generatedCode, {
    required int expectedFactoryCount,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // The map should contain factory functions for each route
    // This is a more complex validation that checks the map literal structure
    final variables =
        unit.declarations.whereType<TopLevelVariableDeclaration>();
    expect(variables, isNotEmpty);

    final mapVar = variables.first;
    final variable = mapVar.variables.variables.first;

    // Check if initializer exists (map literal)
    expect(variable.initializer, isNotNull,
        reason: 'Map should have initializer');

    // The initializer should be a map literal
    final initializer = variable.initializer.toString();
    expect(initializer, contains('{'), reason: 'Should be a map literal');
    expect(initializer, contains('}'), reason: 'Should be a map literal');

    // Check for MaterialPageRoute or similar route factory pattern
    if (expectedFactoryCount > 0) {
      expect(initializer, contains('MaterialPageRoute'),
          reason: 'Should contain route factory functions');
      expect(initializer, contains('builder:'),
          reason: 'Should contain builder functions');
    }
  }
}

/// Complete Router Generation AST validation functions
class CompleteRouterAstValidator {
  /// Validates a complete router generation output (multiple classes + extensions)
  static void validateFullRouterGeneration(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required List<RouteConfig> expectedRoutes,
    required bool shouldHaveNavigationExtension,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // Should contain the main router class
    final routerClass = AstHelper.findClass(unit, routerClassName);
    expect(routerClass, isNotNull,
        reason: 'Should contain $routerClassName class');

    // Validate router class structure (using existing validator)
    RouterAstValidator.validateRouterClassStructure(
      generatedCode,
      expectedClassName: routerClassName,
      expectedSuperclass: 'RouterBase',
    );

    // Should contain routes class if routes exist
    if (expectedRoutes.isNotEmpty) {
      final routesClass = AstHelper.findClass(unit, routesClassName);
      expect(routesClass, isNotNull,
          reason: 'Should contain $routesClassName class');

      validateRoutesClass(generatedCode,
          routesClassName: routesClassName, expectedRoutes: expectedRoutes);
    }

    // Should contain navigation extension if requested
    if (shouldHaveNavigationExtension) {
      validateNavigationExtension(generatedCode,
          expectedRoutes: expectedRoutes);
    }

    // Should contain argument classes for routes with parameters
    final routesWithParams =
        expectedRoutes.where((r) => r.parameters.isNotEmpty);
    if (routesWithParams.isNotEmpty) {
      validateArgumentClasses(generatedCode,
          routesWithParameters: routesWithParams.toList());
    }
  }

  /// Validates the Routes class structure
  static void validateRoutesClass(
    String generatedCode, {
    required String routesClassName,
    required List<RouteConfig> expectedRoutes,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    final routesClass = AstHelper.findClass(unit, routesClassName);

    expect(routesClass, isNotNull);

    // Should have static const fields for each route
    final fields = AstHelper.findFields(routesClass!);
    final staticFields =
        fields.where((f) => f.isStatic && AstHelper.isFieldFinal(f));

    // Should have at least one field per route
    expect(staticFields.length, greaterThanOrEqualTo(expectedRoutes.length),
        reason: 'Should have static const field for each route');

    // Should have an 'all' field with all route names
    final allField = fields
        .where((f) => AstHelper.getFieldVariableNames(f).contains('all'))
        .firstOrNull;
    expect(allField, isNotNull,
        reason: 'Should have "all" field with route names');
  }

  /// Validates navigation extension structure
  static void validateNavigationExtension(
    String generatedCode, {
    required List<RouteConfig> expectedRoutes,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // Should have extension declaration
    final extensions = unit.declarations.whereType<ExtensionDeclaration>();
    expect(extensions, isNotEmpty,
        reason: 'Should contain navigation extension');

    final navExtension = extensions.first;

    // Should have navigate methods for each route
    final methods = navExtension.members.whereType<MethodDeclaration>();
    final navigateMethods =
        methods.where((m) => m.name.lexeme.startsWith('navigateTo'));

    expect(navigateMethods.length, greaterThanOrEqualTo(expectedRoutes.length),
        reason: 'Should have navigateTo method for each route');

    // Should have replace methods for each route
    final replaceMethods =
        methods.where((m) => m.name.lexeme.startsWith('replaceWith'));

    expect(replaceMethods.length, greaterThanOrEqualTo(expectedRoutes.length),
        reason: 'Should have replaceWith method for each route');
  }

  /// Validates argument classes for routes with parameters
  static void validateArgumentClasses(
    String generatedCode, {
    required List<RouteConfig> routesWithParameters,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    for (final route in routesWithParameters) {
      final argumentClassName = '${route.className}Arguments';
      final argumentClass = AstHelper.findClass(unit, argumentClassName);

      expect(argumentClass, isNotNull,
          reason: 'Should contain $argumentClassName class');

      if (argumentClass != null) {
        // Should have constructor
        final constructors =
            argumentClass.members.whereType<ConstructorDeclaration>();
        expect(constructors, isNotEmpty,
            reason: '$argumentClassName should have constructor');

        // Should have fields for each parameter
        final fields = AstHelper.findFields(argumentClass);
        expect(fields.length, greaterThanOrEqualTo(route.parameters.length),
            reason: '$argumentClassName should have field for each parameter');

        // Should have toString method
        final methods = AstHelper.findMethods(argumentClass);
        final toStringMethod =
            methods.where((m) => m.name.lexeme == 'toString').firstOrNull;
        expect(toStringMethod, isNotNull,
            reason: '$argumentClassName should have toString method');
      }
    }
  }

  /// Validates nested router structure (parent/child relationships)
  static void validateNestedRouterStructure(
    String generatedCode, {
    required List<RouteConfig> routesWithChildren,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    for (final parentRoute in routesWithChildren) {
      if (parentRoute.children.isNotEmpty) {
        // Should have nested router class for parent
        final nestedRouterClassName = '${parentRoute.className}Router';
        final nestedRouter = AstHelper.findClass(unit, nestedRouterClassName);

        expect(nestedRouter, isNotNull,
            reason: 'Should contain $nestedRouterClassName for nested routing');

        if (nestedRouter != null) {
          // Nested router should also extend RouterBase
          final superclass = AstHelper.getSuperclassName(nestedRouter);
          expect(superclass, contains('RouterBase'),
              reason: 'Nested router should extend RouterBase');
        }

        // Should have Routes class for children
        final childRoutesClassName = '${parentRoute.className}Routes';
        final childRoutesClass =
            AstHelper.findClass(unit, childRoutesClassName);

        expect(childRoutesClass, isNotNull,
            reason: 'Should contain $childRoutesClassName for child routes');
      }
    }
  }

  /// Validates that imports are appropriate for the generated router complexity
  static void validateRouterImports(
    String generatedCode, {
    required List<RouteConfig> allRoutes,
    required bool hasNavigationExtension,
  }) {
    final unit = AstHelper.parseCode(generatedCode);

    // Should always have stacked import
    expect(AstHelper.hasImport(unit, 'package:stacked/stacked.dart'), isTrue,
        reason: 'Should import stacked package');

    // Should have material import if using MaterialRoute
    final hasMaterialRoutes =
        allRoutes.any((r) => r.routeType == RouteType.material);
    if (hasMaterialRoutes) {
      expect(AstHelper.hasImport(unit, 'package:flutter/material.dart'), isTrue,
          reason: 'Should import flutter/material for MaterialRoutes');
    }

    // Should have navigation service import if has navigation extension
    if (hasNavigationExtension) {
      expect(
          AstHelper.hasImport(
              unit, 'package:stacked_services/stacked_services.dart'),
          isTrue,
          reason: 'Should import stacked_services for navigation extension');
    }

    // Should have imports for each route's class
    for (final route in allRoutes) {
      if (route.classImport.isNotEmpty) {
        expect(AstHelper.hasImport(unit, route.classImport), isTrue,
            reason:
                'Should import ${route.classImport} for ${route.className}');
      }
    }
  }

  /// High-level validation for simple router generation
  static void validateSimpleRouterGeneration(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required List<RouteConfig> routes,
  }) {
    validateFullRouterGeneration(
      generatedCode,
      routerClassName: routerClassName,
      routesClassName: routesClassName,
      expectedRoutes: routes,
      shouldHaveNavigationExtension: true,
    );

    validateRouterImports(
      generatedCode,
      allRoutes: routes,
      hasNavigationExtension: true,
    );
  }

  /// High-level validation for complex nested router generation
  static void validateNestedRouterGeneration(
    String generatedCode, {
    required String routerClassName,
    required String routesClassName,
    required List<RouteConfig> routes,
  }) {
    // All the standard validations
    validateSimpleRouterGeneration(
      generatedCode,
      routerClassName: routerClassName,
      routesClassName: routesClassName,
      routes: routes,
    );

    // Plus nested structure validation
    final routesWithChildren =
        routes.where((r) => r.children.isNotEmpty).toList();

    if (routesWithChildren.isNotEmpty) {
      validateNestedRouterStructure(
        generatedCode,
        routesWithChildren: routesWithChildren,
      );
    }
  }
}
