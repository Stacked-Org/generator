import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/forms/field_config.dart';
import 'package:stacked_generator/src/generators/forms/form_view_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// Form generation AST validation utilities for testing code generation.
///
/// This file contains specialized validators for form code generation
/// in the Stacked framework. The validator handles form mixin generation
/// including imports, value keys, controllers, focus nodes, validation,
/// and form management methods.
///
/// ## Validator Classes:
/// - **FormBuilderAstValidator**: Main form generation validation
/// - **FormFieldAstValidator**: Individual field validation
///
/// ## Usage:
/// ```dart
/// // Validate complete form generation
/// FormBuilderAstValidator.validateFormMixin(
///   generatedCode,
///   expectedFormConfig: formConfig,
/// );
///
/// // Validate specific components
/// FormBuilderAstValidator.validateFormImports(generatedCode);
/// FormBuilderAstValidator.validateValueKeys(generatedCode, expectedFields);
/// FormBuilderAstValidator.validateTextControllers(generatedCode, textFields);
/// ```
///
/// These validators provide semantic validation of generated form code,
/// ensuring the structure and functionality are correct regardless of
/// formatting changes.

/// Main validator for form generation testing.
///
/// This validator focuses on the overall structure of generated form mixins,
/// including imports, value keys, controllers, validation, and form methods.
class FormBuilderAstValidator {
  /// Validates complete form mixin generation.
  ///
  /// Checks for:
  /// - Required imports (Flutter, Stacked)
  /// - Value key constants for all fields
  /// - TextEditingController management
  /// - Focus node management  
  /// - Validation functions
  /// - Form lifecycle methods (dispose, etc.)
  ///
  /// Example:
  /// ```dart
  /// FormBuilderAstValidator.validateFormMixin(
  ///   generatedCode,
  ///   expectedFormConfig: formConfig,
  /// );
  /// ```
  static void validateFormMixin(
    String generatedCode, {
    required FormViewConfig expectedFormConfig,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate required imports
    validateFormImports(generatedCode);
    
    // Validate value keys
    validateValueKeys(generatedCode, expectedFormConfig.fields);
    
    // Validate text controllers for text fields
    final textFields = expectedFormConfig.fields.whereType<TextFieldConfig>();
    if (textFields.isNotEmpty) {
      validateTextControllers(generatedCode, textFields.toList());
    }
    
    // Validate dropdown items maps
    final dropdownFields = expectedFormConfig.fields.whereType<DropdownFieldConfig>();
    if (dropdownFields.isNotEmpty) {
      validateDropdownItemsMaps(generatedCode, dropdownFields.toList());
    }
    
    // Validate mixin structure
    validateMixinStructure(generatedCode, expectedFormConfig.viewName);
  }

  /// Validates that required imports are present.
  ///
  /// Ensures Flutter material and Stacked imports exist.
  static void validateFormImports(String generatedCode) {
    final unit = AstHelper.parseCode(generatedCode);
    
    expect(AstHelper.hasImport(unit, 'package:flutter/material.dart'), 
        isTrue, reason: 'Should import Flutter material');
    expect(AstHelper.hasImport(unit, 'package:stacked/stacked.dart'), 
        isTrue, reason: 'Should import Stacked');
  }

  /// Validates value key constants generation.
  ///
  /// Checks that constants are generated for each field with correct naming.
  static void validateValueKeys(String generatedCode, List<FieldConfig> expectedFields) {
    final unit = AstHelper.parseCode(generatedCode);
    
    for (final field in expectedFields) {
      final keyName = '${_capitalize(field.name)}ValueKey';
      final keyConstant = _findTopLevelConstant(unit, keyName);
      
      expect(keyConstant, isNotNull,
          reason: 'Should have constant $keyName for field ${field.name}');
      
      if (keyConstant != null) {
        // Should be a String constant
        final initializer = keyConstant.initializer.toString();
        expect(initializer, contains("'${field.name}'"),
            reason: '$keyName should contain field name as string value');
      }
    }
  }

  /// Validates TextEditingController management.
  ///
  /// Checks controller map, getters, and lifecycle management.
  static void validateTextControllers(String generatedCode, List<TextFieldConfig> textFields, {
    bool requireGetters = false,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Should have controller map
    final controllerMap = _findTopLevelVariable(unit, r'.*TextEditingControllers$');
    expect(controllerMap, isNotNull,
        reason: 'Should have TextEditingControllers map');
    
    if (controllerMap != null) {
      // Should be Map<String, TextEditingController>
      final mapType = AstHelper.getVariableType(controllerMap);
      expect(mapType, contains('TextEditingController'),
          reason: 'Controller map should be Map<String, TextEditingController>');
    }
    
    // Optionally validate controller getters
    if (requireGetters) {
      _validateControllerGetters(unit, textFields);
    }
  }

  /// Validates dropdown items maps generation.
  ///
  /// Checks that dropdown value-to-title maps are properly generated.
  static void validateDropdownItemsMaps(String generatedCode, List<DropdownFieldConfig> dropdownFields) {
    final unit = AstHelper.parseCode(generatedCode);
    
    for (final field in dropdownFields) {
      // Look for value-to-title map pattern
      final mapVariable = _findTopLevelVariable(unit, r'.*ValueToTitleMap$');
      expect(mapVariable, isNotNull,
          reason: 'Should have value-to-title map for dropdown ${field.name}');
      
      if (mapVariable != null) {
        // Should be Map<String, String>
        final mapType = AstHelper.getVariableType(mapVariable);
        expect(mapType, contains('String'),
            reason: 'Dropdown map should be Map<String, String>');
      }
    }
  }

  /// Validates mixin structure and signature.
  ///
  /// Ensures the generated code includes proper mixin declaration.
  static void validateMixinStructure(String generatedCode, String viewName) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Look for mixin declaration
    final mixins = unit.declarations.whereType<MixinDeclaration>();
    final formMixin = mixins
        .where((m) => m.name.lexeme.contains(viewName) || m.name.lexeme.contains('Form'))
        .firstOrNull;
    
    if (formMixin != null) {
      expect(formMixin, isNotNull,
          reason: 'Should have form mixin for $viewName');
      
      // Should extend FormViewModel or similar
      if (formMixin.onClause != null) {
        final onClause = formMixin.onClause!.superclassConstraints
            .map((t) => t.toString())
            .join(' ');
        expect(onClause, anyOf(contains('FormViewModel'), contains('ViewModel')),
            reason: 'Form mixin should have ViewModel constraint');
      }
    }
  }

  /// Validates form disposal functionality.
  ///
  /// Checks that dispose methods properly clean up controllers and focus nodes.
  static void validateFormDisposal(String generatedCode) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Look for dispose method in mixin
    final mixins = unit.declarations.whereType<MixinDeclaration>();
    for (final mixin in mixins) {
      final disposeMethod = _findMethodInMixin(mixin, 'disposeForm');
      if (disposeMethod != null) {
        // Should call dispose on controllers and focus nodes
        final methodBody = disposeMethod.toString();
        expect(methodBody, contains('dispose()'),
            reason: 'disposeForm should call dispose on resources');
        
        return; // Found dispose method, validation complete
      }
    }
  }

  // Private helper methods

  /// Validates controller getters for text fields.
  static void _validateControllerGetters(CompilationUnit unit, List<TextFieldConfig> textFields) {
    for (final field in textFields) {
      final getterName = '${field.name}Controller';
      
      // Look for getter in mixins
      final mixins = unit.declarations.whereType<MixinDeclaration>();
      bool foundGetter = false;
      
      for (final mixin in mixins) {
        final getter = _findMethodInMixin(mixin, getterName);
        if (getter != null) {
          foundGetter = true;
          
          // Should return TextEditingController
          final returnType = AstHelper.getMethodReturnType(getter);
          expect(returnType, contains('TextEditingController'),
              reason: '$getterName should return TextEditingController');
          break;
        }
      }
      
      if (!foundGetter) {
        // Also check top-level getters
        final functions = unit.declarations.whereType<FunctionDeclaration>();
        final getter = functions
            .where((f) => f.name.lexeme == getterName && f.isGetter)
            .firstOrNull;
        
        expect(getter, isNotNull,
            reason: 'Should have $getterName getter for ${field.name}');
      }
    }
  }

  /// Finds a top-level constant by name.
  static VariableDeclaration? _findTopLevelConstant(CompilationUnit unit, String name) {
    final variables = unit.declarations.whereType<TopLevelVariableDeclaration>();
    
    for (final varDecl in variables) {
      if (varDecl.variables.isConst) {
        for (final variable in varDecl.variables.variables) {
          if (variable.name.lexeme == name) {
            return variable;
          }
        }
      }
    }
    return null;
  }

  /// Finds a top-level variable by name pattern.
  static VariableDeclarationList? _findTopLevelVariable(CompilationUnit unit, String namePattern) {
    final variables = unit.declarations.whereType<TopLevelVariableDeclaration>();
    final regex = RegExp(namePattern);
    
    for (final varDecl in variables) {
      for (final variable in varDecl.variables.variables) {
        if (regex.hasMatch(variable.name.lexeme)) {
          return varDecl.variables;
        }
      }
    }
    return null;
  }

  /// Capitalizes the first letter of a string.
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Finds a method in a mixin declaration.
  static MethodDeclaration? _findMethodInMixin(MixinDeclaration mixin, String methodName) {
    for (final member in mixin.members) {
      if (member is MethodDeclaration && member.name.lexeme == methodName) {
        return member;
      }
    }
    return null;
  }
}

/// Specialized validator for individual form field validation.
///
/// This validator focuses on validating specific field types and their
/// generated code including controllers, validation, and field-specific logic.
class FormFieldAstValidator {
  /// Validates text field code generation.
  ///
  /// Checks controller, validation, and focus node generation for text fields.
  static void validateTextField(
    String generatedCode, {
    required TextFieldConfig expectedField,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Validate value key constant
    final keyName = '${FormBuilderAstValidator._capitalize(expectedField.name)}ValueKey';
    final keyConstant = FormBuilderAstValidator._findTopLevelConstant(unit, keyName);
    expect(keyConstant, isNotNull,
        reason: 'Should have constant $keyName');
    
    // Validate controller getter
    final controllerName = '${expectedField.name}Controller';
    final hasController = _hasMethod(unit, controllerName);
    expect(hasController, isTrue,
        reason: 'Should have $controllerName getter');
  }

  /// Validates dropdown field code generation.
  ///
  /// Checks dropdown items map and value handling.
  static void validateDropdownField(
    String generatedCode, {
    required DropdownFieldConfig expectedField,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Validate value key constant  
    final keyName = '${FormBuilderAstValidator._capitalize(expectedField.name)}ValueKey';
    final keyConstant = FormBuilderAstValidator._findTopLevelConstant(unit, keyName);
    expect(keyConstant, isNotNull,
        reason: 'Should have constant $keyName');
    
    // Validate dropdown items
    if (expectedField.items.isNotEmpty) {
      final mapVariable = FormBuilderAstValidator._findTopLevelVariable(unit, r'.*ValueToTitleMap$');
      expect(mapVariable, isNotNull,
          reason: 'Should have value-to-title map for dropdown ${expectedField.name}');
    }
  }

  /// Validates date field code generation.
  ///
  /// Checks date-specific handling and validation.
  static void validateDateField(
    String generatedCode, {
    required DateFieldConfig expectedField,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Validate value key constant
    final keyName = '${FormBuilderAstValidator._capitalize(expectedField.name)}ValueKey';
    final keyConstant = FormBuilderAstValidator._findTopLevelConstant(unit, keyName);
    expect(keyConstant, isNotNull,
        reason: 'Should have constant $keyName');
  }

  // Private helper methods

  /// Checks if a method exists in the unit (in mixins or top-level).
  static bool _hasMethod(CompilationUnit unit, String methodName) {
    // Check in mixins
    final mixins = unit.declarations.whereType<MixinDeclaration>();
    for (final mixin in mixins) {
      if (_findMethodInMixin(mixin, methodName) != null) {
        return true;
      }
    }
    
    // Check in top-level functions
    final functions = unit.declarations.whereType<FunctionDeclaration>();
    return functions.any((f) => f.name.lexeme == methodName);
  }

  /// Finds a method in a mixin declaration.
  static MethodDeclaration? _findMethodInMixin(MixinDeclaration mixin, String methodName) {
    for (final member in mixin.members) {
      if (member is MethodDeclaration && member.name.lexeme == methodName) {
        return member;
      }
    }
    return null;
  }
}