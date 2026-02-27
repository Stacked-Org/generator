import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/bottomsheets/bottomsheet_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// Bottomsheet-specific AST validation utilities for testing code generation.
///
/// This file contains specialized validators for bottomsheet generation scenarios
/// in the Stacked framework. The validator handles bottomsheet service setup
/// generation including enum creation, import validation, and service
/// registration functions.
///
/// ## Validator Classes:
/// - **BottomsheetClassGeneratorAstValidator**: Bottomsheet service setup validation
///
/// ## Usage:
/// ```dart
/// // Validate empty bottomsheet setup
/// BottomsheetClassGeneratorAstValidator.validateEmptyBottomsheetSetup(
///   generatedCode,
///   expectedLocatorCall: 'locator',
/// );
///
/// // Validate bottomsheet setup with specific bottomsheets
/// BottomsheetClassGeneratorAstValidator.validateBottomsheetSetup(
///   generatedCode,
///   expectedBottomsheets: bottomsheets,
///   expectedLocatorCall: 'customLocator',
/// );
/// ```
///
/// These validators provide semantic validation of generated bottomsheet code,
/// ensuring the structure and functionality are correct regardless of
/// formatting changes.

/// Bottomsheet-specific validation functions for bottomsheet service setup testing.
///
/// This validator focuses on the generation of bottomsheet service setup code,
/// including BottomSheetType enum, import statements, and setupBottomSheetUi function.
class BottomsheetClassGeneratorAstValidator {
  /// Validates bottomsheet service setup generation with no bottomsheets.
  ///
  /// Checks for:
  /// - Required imports (stacked_services, locator)
  /// - Empty BottomSheetType enum
  /// - setupBottomSheetUi function with correct signature
  /// - Proper locator service registration
  ///
  /// Example:
  /// ```dart
  /// BottomsheetClassGeneratorAstValidator.validateEmptyBottomsheetSetup(
  ///   generatedCode,
  ///   expectedLocatorCall: 'locator',
  /// );
  /// ```
  static void validateEmptyBottomsheetSetup(
    String generatedCode, {
    String expectedLocatorCall = 'locator',
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Should have required imports
    _validateRequiredImports(unit);
    
    // Should have empty BottomSheetType enum
    _validateBottomSheetTypeEnum(unit, expectedBottomsheetTypes: []);
    
    // Should have setupBottomSheetUi function
    _validateSetupBottomSheetUiFunction(unit, 
      expectedLocatorCall: expectedLocatorCall, 
      expectedBottomsheetCount: 0
    );
  }

  /// Validates bottomsheet service setup with specified bottomsheets.
  ///
  /// Checks for:
  /// - Required imports plus bottomsheet-specific imports
  /// - BottomSheetType enum with entries for each bottomsheet
  /// - setupBottomSheetUi function with proper builders map
  /// - Correct service registration calls
  ///
  /// Example:
  /// ```dart
  /// BottomsheetClassGeneratorAstValidator.validateBottomsheetSetup(
  ///   generatedCode,
  ///   expectedBottomsheets: bottomsheets,
  ///   expectedLocatorCall: 'customLocator',
  /// );
  /// ```
  static void validateBottomsheetSetup(
    String generatedCode, {
    required List<BottomsheetConfig> expectedBottomsheets,
    String expectedLocatorCall = 'locator',
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Should have required imports plus bottomsheet imports
    _validateRequiredImports(unit);
    _validateBottomsheetImports(unit, expectedBottomsheets);
    
    // Should have BottomSheetType enum with expected entries
    final expectedBottomsheetTypes = expectedBottomsheets
        .map((b) => b.enumValue)
        .toList();
    _validateBottomSheetTypeEnum(unit, expectedBottomsheetTypes: expectedBottomsheetTypes);
    
    // Should have setupBottomSheetUi function with builders map
    _validateSetupBottomSheetUiFunction(unit, 
      expectedLocatorCall: expectedLocatorCall, 
      expectedBottomsheetCount: expectedBottomsheets.length
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

  /// Validates that bottomsheet-specific imports are present.
  ///
  /// Checks that each bottomsheet's import file is properly imported.
  static void _validateBottomsheetImports(CompilationUnit unit, List<BottomsheetConfig> bottomsheets) {
    for (final bottomsheet in bottomsheets) {
      expect(AstHelper.hasImport(unit, bottomsheet.import), 
          isTrue, reason: 'Should import ${bottomsheet.import} for ${bottomsheet.bottomsheetClassName}');
    }
  }

  /// Validates the BottomSheetType enum structure.
  ///
  /// Ensures the enum exists with the correct number of values and
  /// contains all expected bottomsheet type entries.
  static void _validateBottomSheetTypeEnum(CompilationUnit unit, {required List<String> expectedBottomsheetTypes}) {
    // Find the BottomSheetType enum
    EnumDeclaration? bottomsheetTypeEnum;
    for (final declaration in unit.declarations) {
      if (declaration is EnumDeclaration && declaration.name.lexeme == 'BottomSheetType') {
        bottomsheetTypeEnum = declaration;
        break;
      }
    }
    expect(bottomsheetTypeEnum, isNotNull, reason: 'Should contain BottomSheetType enum');
    
    if (bottomsheetTypeEnum != null) {
      final enumValues = bottomsheetTypeEnum.constants.map((c) => c.name.lexeme).toList();
      expect(enumValues.length, equals(expectedBottomsheetTypes.length), 
          reason: 'BottomSheetType enum should have ${expectedBottomsheetTypes.length} values');
      
      for (final expectedType in expectedBottomsheetTypes) {
        expect(enumValues, contains(expectedType), 
            reason: 'BottomSheetType enum should contain $expectedType');
      }
    }
  }

  /// Validates the setupBottomSheetUi function structure.
  ///
  /// Ensures the function has the correct signature, calls the right
  /// locator methods, and properly registers bottomsheet builders.
  static void _validateSetupBottomSheetUiFunction(
    CompilationUnit unit, {
    required String expectedLocatorCall,
    required int expectedBottomsheetCount,
  }) {
    // Find the setupBottomSheetUi function
    FunctionDeclaration? setupFunction;
    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration && 
          declaration.name.lexeme == 'setupBottomSheetUi') {
        setupFunction = declaration;
        break;
      }
    }
    expect(setupFunction, isNotNull, reason: 'Should contain setupBottomSheetUi function');
    
    if (setupFunction != null) {
      // Validate function signature - should be void (either explicit or implicit)
      final returnType = setupFunction.returnType?.toString();
      expect(returnType == null || returnType == 'void', isTrue, 
          reason: 'setupBottomSheetUi should return void (implicit or explicit)');
      expect(setupFunction.functionExpression.parameters?.parameters.length ?? 0, 
          equals(0), reason: 'setupBottomSheetUi should have no parameters');

      // Check function body contains expected elements
      final functionBody = setupFunction.functionExpression.body.toString();
      
      // Should contain locator call (locator or custom locator name)
      expect(functionBody, contains('$expectedLocatorCall<BottomSheetService>()'), 
          reason: 'Should call $expectedLocatorCall<BottomSheetService>()');
      
      // Should contain builders map declaration
      expect(functionBody, contains('Map<BottomSheetType, SheetBuilder>'), 
          reason: 'Should declare builders map');
      
      // Should contain setCustomSheetBuilders call
      expect(functionBody, contains('setCustomSheetBuilders(builders)'), 
          reason: 'Should call setCustomSheetBuilders');
    }
  }
}