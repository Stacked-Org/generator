import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/dialogs/dialog_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// Dialog-specific AST validation utilities for testing code generation.
///
/// This file contains specialized validators for dialog generation scenarios
/// in the Stacked framework. The validator handles dialog service setup
/// generation including enum creation, import validation, and service
/// registration functions.
///
/// ## Validator Classes:
/// - **DialogClassGeneratorAstValidator**: Dialog service setup validation
///
/// ## Usage:
/// ```dart
/// // Validate empty dialog setup
/// DialogClassGeneratorAstValidator.validateEmptyDialogSetup(
///   generatedCode,
///   expectedLocatorCall: 'locator',
/// );
///
/// // Validate dialog setup with specific dialogs
/// DialogClassGeneratorAstValidator.validateDialogSetup(
///   generatedCode,
///   expectedDialogs: dialogs,
///   expectedLocatorCall: 'customLocator',
/// );
/// ```
///
/// These validators provide semantic validation of generated dialog code,
/// ensuring the structure and functionality are correct regardless of
/// formatting changes.

/// Dialog-specific validation functions for dialog service setup testing.
///
/// This validator focuses on the generation of dialog service setup code,
/// including DialogType enum, import statements, and setupDialogUi function.
class DialogClassGeneratorAstValidator {
  /// Validates dialog service setup generation with no dialogs.
  ///
  /// Checks for:
  /// - Required imports (stacked_services, locator)
  /// - Empty DialogType enum
  /// - setupDialogUi function with correct signature
  /// - Proper locator service registration
  ///
  /// Example:
  /// ```dart
  /// DialogClassGeneratorAstValidator.validateEmptyDialogSetup(
  ///   generatedCode,
  ///   expectedLocatorCall: 'locator',
  /// );
  /// ```
  static void validateEmptyDialogSetup(
    String generatedCode, {
    String expectedLocatorCall = 'locator',
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Should have required imports
    _validateRequiredImports(unit);
    
    // Should have empty DialogType enum
    _validateDialogTypeEnum(unit, expectedDialogTypes: []);
    
    // Should have setupDialogUi function
    _validateSetupDialogUiFunction(unit, 
      expectedLocatorCall: expectedLocatorCall, 
      expectedDialogCount: 0
    );
  }

  /// Validates dialog service setup with specified dialogs.
  ///
  /// Checks for:
  /// - Required imports plus dialog-specific imports
  /// - DialogType enum with entries for each dialog
  /// - setupDialogUi function with proper builders map
  /// - Correct service registration calls
  ///
  /// Example:
  /// ```dart
  /// DialogClassGeneratorAstValidator.validateDialogSetup(
  ///   generatedCode,
  ///   expectedDialogs: dialogs,
  ///   expectedLocatorCall: 'customLocator',
  /// );
  /// ```
  static void validateDialogSetup(
    String generatedCode, {
    required List<DialogConfig> expectedDialogs,
    String expectedLocatorCall = 'locator',
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Should have required imports plus dialog imports
    _validateRequiredImports(unit);
    _validateDialogImports(unit, expectedDialogs);
    
    // Should have DialogType enum with expected entries
    final expectedDialogTypes = expectedDialogs
        .map((d) => d.enumValue)
        .toList();
    _validateDialogTypeEnum(unit, expectedDialogTypes: expectedDialogTypes);
    
    // Should have setupDialogUi function with builders map
    _validateSetupDialogUiFunction(unit, 
      expectedLocatorCall: expectedLocatorCall, 
      expectedDialogCount: expectedDialogs.length
    );
  }

  // Private helper methods

  /// Validates that required imports are present.
  ///
  /// Ensures stacked_services and locator imports exist.
  static void _validateRequiredImports(CompilationUnit unit) {
    expect(AstHelper.hasImport(unit, 'package:stacked_services/stacked_services.dart'), 
        isTrue, reason: 'Should import stacked_services');
    expect(AstHelper.hasImport(unit, 'app.locator.dart'), 
        isTrue, reason: 'Should import app.locator.dart');
  }

  /// Validates that dialog-specific imports are present.
  ///
  /// Checks that each dialog's import file is properly imported.
  static void _validateDialogImports(CompilationUnit unit, List<DialogConfig> dialogs) {
    for (final dialog in dialogs) {
      expect(AstHelper.hasImport(unit, dialog.import), 
          isTrue, reason: 'Should import ${dialog.import} for ${dialog.dialogClassName}');
    }
  }

  /// Validates the DialogType enum structure.
  ///
  /// Ensures the enum exists with the correct number of values and
  /// contains all expected dialog type entries.
  static void _validateDialogTypeEnum(CompilationUnit unit, {required List<String> expectedDialogTypes}) {
    // Find the DialogType enum
    EnumDeclaration? dialogTypeEnum;
    for (final declaration in unit.declarations) {
      if (declaration is EnumDeclaration && declaration.name.lexeme == 'DialogType') {
        dialogTypeEnum = declaration;
        break;
      }
    }
    expect(dialogTypeEnum, isNotNull, reason: 'Should contain DialogType enum');
    
    if (dialogTypeEnum != null) {
      final enumValues = dialogTypeEnum.constants.map((c) => c.name.lexeme).toList();
      expect(enumValues.length, equals(expectedDialogTypes.length), 
          reason: 'DialogType enum should have ${expectedDialogTypes.length} values');
      
      for (final expectedType in expectedDialogTypes) {
        expect(enumValues, contains(expectedType), 
            reason: 'DialogType enum should contain $expectedType');
      }
    }
  }

  /// Validates the setupDialogUi function structure.
  ///
  /// Ensures the function has the correct signature, calls the right
  /// locator methods, and properly registers dialog builders.
  static void _validateSetupDialogUiFunction(
    CompilationUnit unit, {
    required String expectedLocatorCall,
    required int expectedDialogCount,
  }) {
    // Find the setupDialogUi function
    FunctionDeclaration? setupFunction;
    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration && 
          declaration.name.lexeme == 'setupDialogUi') {
        setupFunction = declaration;
        break;
      }
    }
    expect(setupFunction, isNotNull, reason: 'Should contain setupDialogUi function');
    
    if (setupFunction != null) {
      // Validate function signature - should be void (either explicit or implicit)
      final returnType = setupFunction.returnType?.toString();
      expect(returnType == null || returnType == 'void', isTrue, 
          reason: 'setupDialogUi should return void (implicit or explicit)');
      expect(setupFunction.functionExpression.parameters?.parameters.length ?? 0, 
          equals(0), reason: 'setupDialogUi should have no parameters');

      // Check function body contains expected elements
      final functionBody = setupFunction.functionExpression.body.toString();
      
      // Should contain locator call (locator or custom locator name)
      expect(functionBody, contains('$expectedLocatorCall<DialogService>()'), 
          reason: 'Should call $expectedLocatorCall<DialogService>()');
      
      // Should contain builders map declaration
      expect(functionBody, contains('Map<DialogType, DialogBuilder>'), 
          reason: 'Should declare builders map');
      
      // Should contain registerCustomDialogBuilders call
      expect(functionBody, contains('registerCustomDialogBuilders(builders)'), 
          reason: 'Should call registerCustomDialogBuilders');
    }
  }
}