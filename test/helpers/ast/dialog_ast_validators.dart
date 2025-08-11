import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/dialogs/dialog_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// Dialog-specific AST validators for generated dialog setup code.
/// Validates imports, DialogType enum values, and setupDialogUi registration.
/// Uses semantic (AST) checks so tests are resilient to formatting changes.
/// Apply in dialog code generation tests via DialogClassGeneratorAstValidator.

/// Validator for dialog service setup code.
/// Checks imports, DialogType enum contents, and setupDialogUi registration.
/// Prefer semantic structure checks over string comparisons.
class DialogClassGeneratorAstValidator {
  /// Validate an empty dialog setup.
  /// Ensures required imports, an empty DialogType enum,
  /// and a setupDialogUi function that registers with the expected locator.
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
        expectedLocatorCall: expectedLocatorCall, expectedDialogCount: 0);
  }

  /// Validate dialog setup containing dialogs.
  /// Ensures required + dialog imports, DialogType entries for each dialog,
  /// and setupDialogUi that registers builders via the expected locator.
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
    final expectedDialogTypes =
        expectedDialogs.map((d) => d.enumValue).toList();
    _validateDialogTypeEnum(unit, expectedDialogTypes: expectedDialogTypes);

    // Should have setupDialogUi function with builders map
    _validateSetupDialogUiFunction(unit,
        expectedLocatorCall: expectedLocatorCall,
        expectedDialogCount: expectedDialogs.length);
  }

  // Private helper methods

  /// Ensure core imports exist (stacked_services and app.locator.dart).
  static void _validateRequiredImports(CompilationUnit unit) {
    expect(
        AstHelper.hasImport(
            unit, 'package:stacked_services/stacked_services.dart'),
        isTrue,
        reason: 'Should import stacked_services');
    expect(AstHelper.hasImport(unit, 'app.locator.dart'), isTrue,
        reason: 'Should import app.locator.dart');
  }

  /// Ensure each dialog's import is present for all expected dialogs.
  static void _validateDialogImports(
      CompilationUnit unit, List<DialogConfig> dialogs) {
    for (final dialog in dialogs) {
      expect(AstHelper.hasImport(unit, dialog.import), isTrue,
          reason:
              'Should import ${dialog.import} for ${dialog.dialogClassName}');
    }
  }

  /// Ensure DialogType enum exists and contains the expected values.
  static void _validateDialogTypeEnum(CompilationUnit unit,
      {required List<String> expectedDialogTypes}) {
    // Find the DialogType enum
    EnumDeclaration? dialogTypeEnum;
    for (final declaration in unit.declarations) {
      if (declaration is EnumDeclaration &&
          declaration.name.lexeme == 'DialogType') {
        dialogTypeEnum = declaration;
        break;
      }
    }
    expect(dialogTypeEnum, isNotNull, reason: 'Should contain DialogType enum');

    if (dialogTypeEnum != null) {
      final enumValues =
          dialogTypeEnum.constants.map((c) => c.name.lexeme).toList();
      expect(enumValues.length, equals(expectedDialogTypes.length),
          reason:
              'DialogType enum should have ${expectedDialogTypes.length} values');

      for (final expectedType in expectedDialogTypes) {
        expect(enumValues, contains(expectedType),
            reason: 'DialogType enum should contain $expectedType');
      }
    }
  }

  /// Ensure setupDialogUi exists, returns void, uses the expected locator,
  /// declares a builders map, and registers it via registerCustomDialogBuilders.
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
    expect(setupFunction, isNotNull,
        reason: 'Should contain setupDialogUi function');

    if (setupFunction != null) {
      // Validate function signature - should be void (either explicit or implicit)
      final returnType = setupFunction.returnType?.toString();
      expect(returnType == null || returnType == 'void', isTrue,
          reason: 'setupDialogUi should return void (implicit or explicit)');
      expect(
          setupFunction.functionExpression.parameters?.parameters.length ?? 0,
          equals(0),
          reason: 'setupDialogUi should have no parameters');

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
