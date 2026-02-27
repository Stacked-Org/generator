import 'package:analyzer/dart/ast/ast.dart';
import 'package:stacked_generator/src/generators/logging/logger_config.dart';
import 'package:test/test.dart';

import 'ast_helper.dart';

/// Logger generation AST validation utilities for testing code generation.
///
/// This file contains specialized validators for logger code generation
/// in the Stacked framework. The validator handles logger class generation
/// including imports, SimpleLogPrinter class, stack trace utilities,
/// and logger factory functions with conditional compilation.
///
/// ## Validator Classes:
/// - **LoggerClassGeneratorAstValidator**: Main logger generation validation
/// - **LoggerComponentAstValidator**: Individual component validation
///
/// ## Usage:
/// ```dart
/// // Validate complete logger generation
/// LoggerClassGeneratorAstValidator.validateLoggerGeneration(
///   generatedCode,
///   expectedConfig: loggerConfig,
/// );
///
/// // Validate specific components
/// LoggerClassGeneratorAstValidator.validateLoggerImports(
///   generatedCode, 
///   expectedImports
/// );
/// LoggerComponentAstValidator.validateSimpleLogPrinter(generatedCode);
/// LoggerComponentAstValidator.validateLoggerFactory(
///   generatedCode, 
///   expectedFunctionName
/// );
/// ```
///
/// These validators provide semantic validation of generated logger code,
/// ensuring the structure and functionality are correct regardless of
/// formatting changes.

/// Main validator for logger generation testing.
///
/// This validator focuses on the overall structure of generated logger files,
/// including imports, printer class, utility functions, and factory function.
class LoggerClassGeneratorAstValidator {
  /// Validates complete logger generation.
  ///
  /// Checks for:
  /// - Required imports (Flutter foundation, logger package, custom imports)
  /// - SimpleLogPrinter class with proper structure
  /// - Stack trace utility functions
  /// - Logger factory function with correct signature
  /// - Conditional compilation logic for outputs
  ///
  /// Example:
  /// ```dart
  /// LoggerClassGeneratorAstValidator.validateLoggerGeneration(
  ///   generatedCode,
  ///   expectedConfig: loggerConfig,
  /// );
  /// ```
  static void validateLoggerGeneration(
    String generatedCode, {
    required LoggerConfig expectedConfig,
  }) {
    final unit = AstHelper.parseCode(generatedCode);
    expect(unit, isNotNull, reason: 'Generated code should be valid Dart');

    // Validate required imports
    validateLoggerImports(generatedCode, expectedConfig.imports);
    
    // Validate SimpleLogPrinter class
    LoggerComponentAstValidator.validateSimpleLogPrinter(generatedCode);
    
    // Validate stack trace utility functions
    LoggerComponentAstValidator.validateStackTraceUtilities(generatedCode);
    
    // Validate logger factory function
    LoggerComponentAstValidator.validateLoggerFactory(
      generatedCode, 
      expectedConfig.logHelperName,
      expectedConfig.loggerOutputs,
      expectedConfig.disableReleaseConsoleOutput,
    );
  }

  /// Validates that required imports are present.
  ///
  /// Ensures Flutter foundation, logger package, and custom imports exist.
  static void validateLoggerImports(String generatedCode, Set<String> expectedImports) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Required framework imports
    expect(AstHelper.hasImport(unit, 'package:flutter/foundation.dart'), 
        isTrue, reason: 'Should import Flutter foundation');
    expect(AstHelper.hasImport(unit, 'package:logger/logger.dart'), 
        isTrue, reason: 'Should import logger package');
    
    // Custom imports from config
    for (final importPath in expectedImports) {
      expect(AstHelper.hasImport(unit, importPath), 
          isTrue, reason: 'Should import $importPath');
    }
  }

  /// Validates ignore comments for linting.
  ///
  /// Checks that proper ignore directives are present.
  static void validateIgnoreComments(String generatedCode) {
    // Check for ignore comments at the top of the file
    expect(generatedCode, contains('ignore_for_file'),
        reason: 'Should contain ignore_for_file directive');
    expect(generatedCode, contains('avoid_print'),
        reason: 'Should ignore avoid_print linting rule');
    expect(generatedCode, contains('depend_on_referenced_packages'),
        reason: 'Should ignore depend_on_referenced_packages linting rule');
  }
}

/// Specialized validator for individual logger components.
///
/// This validator focuses on validating specific parts of the logger
/// generation including printer class, utility functions, and factory methods.
class LoggerComponentAstValidator {
  /// Validates SimpleLogPrinter class structure.
  ///
  /// Checks class declaration, constructor, fields, and log method.
  static void validateSimpleLogPrinter(String generatedCode) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Find SimpleLogPrinter class
    final printerClass = AstHelper.findClass(unit, 'SimpleLogPrinter');
    expect(printerClass, isNotNull,
        reason: 'Should contain SimpleLogPrinter class');
    
    if (printerClass != null) {
      // Should extend LogPrinter
      final extendsClause = printerClass.extendsClause;
      expect(extendsClause?.superclass.name2.lexeme, equals('LogPrinter'),
          reason: 'SimpleLogPrinter should extend LogPrinter');
      
      // Validate required fields
      _validatePrinterFields(printerClass);
      
      // Validate constructor
      _validatePrinterConstructor(printerClass);
      
      // Validate log method
      _validateLogMethod(printerClass);
      
      // Validate helper methods
      _validatePrinterHelperMethods(printerClass);
    }
  }

  /// Validates stack trace utility functions.
  ///
  /// Checks for global utility functions and variables.
  static void validateStackTraceUtilities(String generatedCode) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Should have stackTraceRegex variable
    final stackTraceRegex = _findTopLevelVariable(unit, 'stackTraceRegex');
    expect(stackTraceRegex, isNotNull,
        reason: 'Should have stackTraceRegex variable');
    
    if (stackTraceRegex != null) {
      // Should contain RegExp in the initializer
      final firstVariable = stackTraceRegex.variables.first;
      final initializer = firstVariable.initializer?.toString() ?? '';
      expect(initializer, contains('RegExp'),
          reason: 'stackTraceRegex should be initialized with RegExp');
    }
    
    // Should have _formatStackTrace function
    final formatFunction = _findTopLevelFunction(unit, '_formatStackTrace');
    expect(formatFunction, isNotNull,
        reason: 'Should have _formatStackTrace function');
    
    if (formatFunction != null) {
      // Should return List<String>?
      final returnType = formatFunction.returnType?.toString();
      expect(returnType, anyOf(contains('List'), contains('String')),
          reason: '_formatStackTrace should return List<String>?');
      
      // Should have StackTrace and int parameters
      final parameters = formatFunction.functionExpression.parameters?.parameters ?? [];
      expect(parameters.length, equals(2),
          reason: '_formatStackTrace should have 2 parameters');
    }
  }

  /// Validates logger factory function.
  ///
  /// Checks function signature, parameters, and output configuration.
  static void validateLoggerFactory(
    String generatedCode, 
    String expectedFunctionName,
    List<String> expectedOutputs,
    bool? disableReleaseConsoleOutput,
  ) {
    final unit = AstHelper.parseCode(generatedCode);
    
    // Find the logger factory function
    final factoryFunction = _findTopLevelFunction(unit, expectedFunctionName);
    expect(factoryFunction, isNotNull,
        reason: 'Should have $expectedFunctionName factory function');
    
    if (factoryFunction != null) {
      // Should return Logger
      final returnType = factoryFunction.returnType?.toString();
      expect(returnType, contains('Logger'),
          reason: '$expectedFunctionName should return Logger');
      
      // Validate function parameters
      _validateFactoryParameters(factoryFunction);
      
      // Validate function body contains expected outputs
      _validateFactoryOutputs(factoryFunction, expectedOutputs, disableReleaseConsoleOutput);
    }
  }

  // Private helper methods

  /// Validates SimpleLogPrinter fields.
  static void _validatePrinterFields(ClassDeclaration printerClass) {
    final expectedFields = [
      'className',
      'printCallingFunctionName', 
      'printCallStack',
      'exludeLogsFromClasses',
      'showOnlyClass',
      'printer',
    ];
    
    for (final fieldName in expectedFields) {
      final field = AstHelper.findField(printerClass, fieldName);
      expect(field, isNotNull,
          reason: 'SimpleLogPrinter should have $fieldName field');
      
      if (field != null && fieldName != 'printer') {
        // Most fields should be final
        expect(AstHelper.isFieldFinal(field), isTrue,
            reason: '$fieldName field should be final');
      }
    }
  }

  /// Validates SimpleLogPrinter constructor.
  static void _validatePrinterConstructor(ClassDeclaration printerClass) {
    final constructor = AstHelper.findConstructor(printerClass, 'SimpleLogPrinter');
    expect(constructor, isNotNull,
        reason: 'SimpleLogPrinter should have constructor');
    
    if (constructor != null) {
      // Should have className as required parameter
      final parameters = constructor.parameters.parameters;
      expect(parameters, isNotEmpty,
          reason: 'Constructor should have parameters');
      
      // First parameter should be className
      final firstParam = parameters.first;
      expect(firstParam.toString(), contains('className'),
          reason: 'First parameter should be className');
    }
  }

  /// Validates log method in SimpleLogPrinter.
  static void _validateLogMethod(ClassDeclaration printerClass) {
    final logMethod = AstHelper.findMethod(printerClass, 'log');
    expect(logMethod, isNotNull,
        reason: 'SimpleLogPrinter should have log method');
    
    if (logMethod != null) {
      // Should have override annotation
      expect(AstHelper.hasOverrideAnnotation(logMethod), isTrue,
          reason: 'log method should have @override annotation');
      
      // Should return List<String>
      final returnType = AstHelper.getMethodReturnType(logMethod);
      expect(returnType, anyOf(contains('List'), contains('String')),
          reason: 'log method should return List<String>');
    }
  }

  /// Validates SimpleLogPrinter helper methods.
  static void _validatePrinterHelperMethods(ClassDeclaration printerClass) {
    final helperMethods = ['_getMethodName', '_splitClassNameWords', 
                          '_findMostMatchedTrace', '_doesTraceContainsAllKeywords'];
    
    for (final methodName in helperMethods) {
      final method = AstHelper.findMethod(printerClass, methodName);
      expect(method, isNotNull,
          reason: 'SimpleLogPrinter should have $methodName method');
    }
  }

  /// Validates factory function parameters.
  static void _validateFactoryParameters(FunctionDeclaration factoryFunction) {
    final parameters = factoryFunction.functionExpression.parameters?.parameters ?? [];
    final expectedParams = [
      'className',
      'printCallingFunctionName',
      'printCallstack', 
      'exludeLogsFromClasses',
      'showOnlyClass'
    ];
    
    // Should have at least the required parameters
    expect(parameters.length, greaterThanOrEqualTo(1),
        reason: 'Factory function should have parameters');
    
    // Check parameter names are present in function signature
    final functionSignature = factoryFunction.toString();
    for (final paramName in expectedParams) {
      expect(functionSignature, contains(paramName),
          reason: 'Factory function should have $paramName parameter');
    }
  }

  /// Validates factory function output configuration.
  static void _validateFactoryOutputs(
    FunctionDeclaration factoryFunction, 
    List<String> expectedOutputs,
    bool? disableReleaseConsoleOutput,
  ) {
    final functionBody = factoryFunction.toString();
    
    // Should contain MultiOutput
    expect(functionBody, contains('MultiOutput'),
        reason: 'Factory function should use MultiOutput');
    
    // Should contain Logger instantiation
    expect(functionBody, contains('Logger('),
        reason: 'Factory function should instantiate Logger');
    
    // Should contain SimpleLogPrinter
    expect(functionBody, contains('SimpleLogPrinter'),
        reason: 'Factory function should use SimpleLogPrinter');
    
    // Check console output conditional logic
    if (disableReleaseConsoleOutput == false) {
      expect(functionBody, contains('ConsoleOutput()'),
          reason: 'Should always include ConsoleOutput when not disabled');
    } else {
      expect(functionBody, contains('kReleaseMode'),
          reason: 'Should have conditional compilation logic');
    }
    
    // Check expected outputs are referenced
    for (final output in expectedOutputs) {
      expect(functionBody, contains(output),
          reason: 'Should reference output $output');
    }
  }

  /// Finds a top-level variable by name.
  static VariableDeclarationList? _findTopLevelVariable(CompilationUnit unit, String name) {
    final variables = unit.declarations.whereType<TopLevelVariableDeclaration>();
    
    for (final varDecl in variables) {
      for (final variable in varDecl.variables.variables) {
        if (variable.name.lexeme == name) {
          return varDecl.variables;
        }
      }
    }
    return null;
  }

  /// Finds a top-level function by name.
  static FunctionDeclaration? _findTopLevelFunction(CompilationUnit unit, String name) {
    final functions = unit.declarations.whereType<FunctionDeclaration>();
    return functions.where((f) => f.name.lexeme == name).firstOrNull;
  }
}