import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/getit/dependency_config/dependency_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// GetIt/Dependency Injection AST validation utilities for testing code generation.
///
/// This file contains specialized validators for GetIt locator code generation
/// in the Stacked framework. The validator handles dependency injection setup
/// including imports, locator variable, setup function, and service registration.
///
/// ## Validator Classes:
/// - **StackedLocatorContentGeneratorAstValidator**: Main locator setup validation
/// - **DependencyRegistrationAstValidator**: Individual dependency validation
///
/// ## Usage:
/// ```dart
/// // Validate complete locator setup
/// StackedLocatorContentGeneratorAstValidator.validateLocatorSetup(
///   generatedCode,
///   expectedDependencies: dependencies,
///   expectedLocatorName: 'customLocator',
///   expectedSetupName: 'setupLocator',
/// );
///
/// // Validate specific dependency types
/// DependencyRegistrationAstValidator.validateSingletonRegistration(
///   generatedCode,
///   expectedDependency: dependency,
/// );
/// ```
///
/// These validators provide semantic validation of generated locator code,
/// ensuring the structure and functionality are correct regardless of
/// formatting changes.

/// Main validator for GetIt locator content generation.
///
/// This validator focuses on the overall structure of generated locator files,
/// including imports, locator variable declaration, setup function signature,
/// and dependency registration calls.
class StackedLocatorContentGeneratorAstValidator {
  /// Validates complete locator setup generation.
  ///
  /// Checks for:
  /// - Required imports (stacked_shared, dependency imports)
  /// - Locator variable declaration with correct name and type
  /// - Setup function with correct signature and parameters
  /// - Environment registration setup
  /// - All dependency registration calls
  ///
  /// Example:
  /// ```dart
  /// StackedLocatorContentGeneratorAstValidator.validateLocatorSetup(
  ///   generatedCode,
  ///   expectedDependencies: dependencies,
  ///   expectedLocatorName: 'appLocator',
  ///   expectedSetupName: 'setupAppLocator',
  /// );
  /// ```
  static void validateLocatorSetup(
    String generatedCode, {
    required List<DependencyConfig> expectedDependencies,
    required String expectedLocatorName,
    required String expectedSetupName,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate required imports
    _validateRequiredImports(unit, expectedDependencies);
    
    // Validate locator variable declaration
    _validateLocatorVariable(unit, expectedLocatorName);
    
    // Validate setup function
    _validateSetupFunction(unit, expectedSetupName, expectedLocatorName, expectedDependencies);
  }

  /// Validates locator setup with no dependencies.
  ///
  /// Ensures basic structure is correct even when no services are registered.
  static void validateEmptyLocatorSetup(
    String generatedCode, {
    required String expectedLocatorName,
    required String expectedSetupName,
  }) {
    validateLocatorSetup(
      generatedCode,
      expectedDependencies: [],
      expectedLocatorName: expectedLocatorName,
      expectedSetupName: expectedSetupName,
    );
  }

  // Private helper methods

  /// Validates that required imports are present.
  static void _validateRequiredImports(CompilationUnit unit, List<DependencyConfig> dependencies) {
    // Should always import stacked_shared
    expect(AstHelper.hasImport(unit, 'package:stacked_shared/stacked_shared.dart'), 
        isTrue, reason: 'Should import stacked_shared');

    // Should import each dependency's import
    for (final dependency in dependencies) {
      expect(AstHelper.hasImport(unit, dependency.import), 
          isTrue, reason: 'Should import ${dependency.import} for ${dependency.className}');
    }
  }

  /// Validates locator variable declaration.
  static void _validateLocatorVariable(CompilationUnit unit, String expectedLocatorName) {
    // Find the locator variable
    final variables = unit.declarations.whereType<TopLevelVariableDeclaration>();
    final locatorVar = variables
        .where((v) => AstHelper.getVariableNames(v.variables).contains(expectedLocatorName))
        .firstOrNull;
    
    expect(locatorVar, isNotNull, 
        reason: 'Should contain locator variable $expectedLocatorName');

    if (locatorVar != null) {
      // Should be final
      expect(AstHelper.isVariableFinal(locatorVar.variables), isTrue,
          reason: 'Locator variable should be final');

      // Should be StackedLocator.instance
      final initializer = locatorVar.variables.variables.first.initializer.toString();
      expect(initializer, contains('StackedLocator.instance'),
          reason: 'Locator should be initialized with StackedLocator.instance');
    }
  }

  /// Validates setup function structure and content.
  static void _validateSetupFunction(
    CompilationUnit unit, 
    String expectedSetupName, 
    String expectedLocatorName,
    List<DependencyConfig> expectedDependencies
  ) {
    // Find the setup function
    final setupFunction = unit.declarations
        .whereType<FunctionDeclaration>()
        .where((f) => f.name.lexeme == expectedSetupName)
        .firstOrNull;
    
    expect(setupFunction, isNotNull, 
        reason: 'Should contain setup function $expectedSetupName');

    if (setupFunction != null) {
      // Should be async and return Future<void>
      expect(setupFunction.functionExpression.body.isAsynchronous, isTrue,
          reason: 'Setup function should be async');
      
      final returnType = setupFunction.returnType?.toString();
      expect(returnType, anyOf(contains('Future'), isNull),
          reason: 'Setup function should return Future<void>');

      // Should have environment and environmentFilter parameters
      final parameters = setupFunction.functionExpression.parameters?.parameters ?? [];
      final paramNames = parameters.map((p) => p.toString()).join(' ');
      expect(paramNames, contains('environment'),
          reason: 'Setup function should have environment parameter');
      expect(paramNames, contains('environmentFilter'),
          reason: 'Setup function should have environmentFilter parameter');

      // Check function body contains expected elements
      final functionBody = setupFunction.functionExpression.body.toString();
      
      // Should contain environment registration
      expect(functionBody, contains('registerEnvironment'),
          reason: 'Should call registerEnvironment');
      
      // Should contain dependency registrations
      for (final dependency in expectedDependencies) {
        _validateDependencyRegistrationInBody(functionBody, dependency, expectedLocatorName);
      }
    }
  }

  /// Validates that a specific dependency registration appears in function body.
  static void _validateDependencyRegistrationInBody(
    String functionBody, 
    DependencyConfig dependency, 
    String locatorName
  ) {
    // Should contain locator call for this dependency
    expect(functionBody, contains('$locatorName.register'),
        reason: 'Should call $locatorName.register for ${dependency.className}');
    
    // Should contain the class name
    expect(functionBody, contains(dependency.className),
        reason: 'Should register ${dependency.className}');
  }
}

/// Specialized validator for individual dependency registration validation.
///
/// This validator focuses on validating specific types of dependency
/// registrations including singleton, factory, lazy singleton, etc.
class DependencyRegistrationAstValidator {
  /// Validates singleton dependency registration.
  ///
  /// Checks that singleton registration calls are properly formatted.
  static void validateSingletonRegistration(
    String generatedCode, {
    required DependencyConfig expectedDependency,
    required String locatorName,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    final functionBody = _getSetupFunctionBody(unit);
    
    // Should contain registerSingleton call
    expect(functionBody, contains('$locatorName.registerSingleton'),
        reason: 'Should call registerSingleton for ${expectedDependency.className}');
    
    // Should contain class instantiation
    expect(functionBody, contains('${expectedDependency.className}()'),
        reason: 'Should instantiate ${expectedDependency.className}');
  }

  /// Validates factory dependency registration.
  ///
  /// Checks that factory registration calls are properly formatted.
  static void validateFactoryRegistration(
    String generatedCode, {
    required DependencyConfig expectedDependency,
    required String locatorName,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    final functionBody = _getSetupFunctionBody(unit);
    
    // Should contain registerFactory call
    expect(functionBody, contains('$locatorName.registerFactory'),
        reason: 'Should call registerFactory for ${expectedDependency.className}');
    
    // Should contain class instantiation
    expect(functionBody, contains('${expectedDependency.className}()'),
        reason: 'Should instantiate ${expectedDependency.className}');
  }

  /// Validates lazy singleton dependency registration.
  ///
  /// Checks that lazy singleton registration calls are properly formatted.
  static void validateLazySingletonRegistration(
    String generatedCode, {
    required DependencyConfig expectedDependency,
    required String locatorName,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    final functionBody = _getSetupFunctionBody(unit);
    
    // Should contain registerLazySingleton call
    expect(functionBody, contains('$locatorName.registerLazySingleton'),
        reason: 'Should call registerLazySingleton for ${expectedDependency.className}');
    
    // Should contain lambda function
    expect(functionBody, contains('=>'),
        reason: 'Should use lambda function for lazy singleton');
  }

  /// Validates factory with parameters dependency registration.
  ///
  /// Checks that factory with parameters registration calls include
  /// proper parameter handling and lambda functions.
  static void validateFactoryWithParamsRegistration(
    String generatedCode, {
    required DependencyConfig expectedDependency,
    required String locatorName,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    final functionBody = _getSetupFunctionBody(unit);
    
    // Should contain registerFactoryParam call
    expect(functionBody, contains('$locatorName.registerFactoryParam'),
        reason: 'Should call registerFactoryParam for ${expectedDependency.className}');
    
    // Should contain parameter lambda
    expect(functionBody, contains('=>'),
        reason: 'Should use lambda function for factory with params');
  }

  // Private helper methods

  /// Extracts the setup function body as string for validation.
  static String _getSetupFunctionBody(CompilationUnit unit) {
    final setupFunction = unit.declarations
        .whereType<FunctionDeclaration>()
        .firstOrNull;
    
    expect(setupFunction, isNotNull, reason: 'Should have setup function');
    return setupFunction!.functionExpression.body.toString();
  }
}