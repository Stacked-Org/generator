import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Core AST parsing and navigation utilities for code generation tests.
///
/// This class provides low-level utilities for parsing Dart code into AST
/// and navigating the resulting tree structure. These methods are used by
/// domain-specific validators to perform semantic validation of generated code.
///
/// ## Key Features:
/// - **AST Parsing**: Parse Dart code strings into CompilationUnit objects
/// - **Class Navigation**: Find and inspect class declarations
/// - **Method/Field Discovery**: Locate methods and fields within classes
/// - **Import Analysis**: Check for required imports
/// - **Type Analysis**: Extract type information from declarations
/// - **Extension Support**: Work with extension declarations
///
/// ## Usage:
/// ```dart
/// final unit = AstHelper.parseCode(generatedCode);
/// final myClass = AstHelper.findClass(unit, 'MyClass');
/// final method = AstHelper.findMethod(myClass!, 'myMethod');
/// ```
///
/// This helper is designed to be used by domain-specific validators like:
/// - RouterAstValidator
/// - DialogClassGeneratorAstValidator
/// - And other code generation validators
class AstHelper {
  /// Parses Dart code string into a CompilationUnit AST.
  ///
  /// Throws a test failure if the code contains parse errors.
  ///
  /// Example:
  /// ```dart
  /// final unit = AstHelper.parseCode('class MyClass {}');
  /// ```
  static CompilationUnit parseCode(String code) {
    final result = parseString(content: code);
    if (result.errors.isNotEmpty) {
      fail('Failed to parse code: ${result.errors.first}');
    }
    return result.unit;
  }

  // ========== Class and Declaration Finders ==========

  /// Finds a class declaration by name in the compilation unit.
  ///
  /// Returns null if no class with the given name is found.
  ///
  /// Example:
  /// ```dart
  /// final myClass = AstHelper.findClass(unit, 'MyClass');
  /// if (myClass != null) {
  ///   // Class found, can inspect its members
  /// }
  /// ```
  static ClassDeclaration? findClass(CompilationUnit unit, String className) {
    return unit.declarations
        .whereType<ClassDeclaration>()
        .where((c) => c.name.lexeme == className)
        .firstOrNull;
  }

  /// Finds extension declaration by name in the compilation unit.
  ///
  /// Returns null if no extension with the given name is found.
  static ExtensionDeclaration? findExtension(CompilationUnit unit, String extensionName) {
    return unit.declarations
        .whereType<ExtensionDeclaration>()
        .where((e) => e.name?.lexeme == extensionName)
        .firstOrNull;
  }

  // ========== Class Member Finders ==========

  /// Finds all method declarations in a class.
  ///
  /// Returns an empty list if the class has no methods.
  static List<MethodDeclaration> findMethods(ClassDeclaration classDecl) {
    return classDecl.members.whereType<MethodDeclaration>().toList();
  }

  /// Finds all field declarations in a class.
  ///
  /// Returns an empty list if the class has no fields.
  static List<FieldDeclaration> findFields(ClassDeclaration classDecl) {
    return classDecl.members.whereType<FieldDeclaration>().toList();
  }

  /// Finds a specific method by name in a class.
  ///
  /// Returns null if no method with the given name is found.
  ///
  /// Example:
  /// ```dart
  /// final method = AstHelper.findMethod(myClass, 'myMethod');
  /// ```
  static MethodDeclaration? findMethod(
      ClassDeclaration classDecl, String methodName) {
    return findMethods(classDecl)
        .where((m) => m.name.lexeme == methodName)
        .firstOrNull;
  }

  /// Finds a specific field by name in a class.
  ///
  /// Returns null if no field with the given name is found.
  /// Searches through all variables in field declarations.
  static FieldDeclaration? findField(
      ClassDeclaration classDecl, String fieldName) {
    return findFields(classDecl)
        .where((f) => f.fields.variables.any((v) => v.name.lexeme == fieldName))
        .firstOrNull;
  }

  /// Finds a constructor by name in a class.
  ///
  /// For default constructors, pass the class name as constructorName.
  /// Returns null if no constructor with the given name is found.
  static ConstructorDeclaration? findConstructor(
      ClassDeclaration classDecl, String constructorName) {
    return classDecl.members
        .whereType<ConstructorDeclaration>()
        .where((c) => c.name?.lexeme == constructorName || (c.name == null && constructorName == classDecl.name.lexeme))
        .firstOrNull;
  }

  /// Finds a method by name in an extension declaration.
  ///
  /// Returns null if no method with the given name is found.
  static MethodDeclaration? findMethodInExtension(
      ExtensionDeclaration extension, String methodName) {
    return extension.members
        .whereType<MethodDeclaration>()
        .where((m) => m.name.lexeme == methodName)
        .firstOrNull;
  }

  // ========== Import Analysis ==========

  /// Gets all import directives from the compilation unit.
  ///
  /// Useful for analyzing what packages and files are imported.
  static List<ImportDirective> getImports(CompilationUnit unit) {
    return unit.directives.whereType<ImportDirective>().toList();
  }

  /// Checks if a specific import exists by URI.
  ///
  /// Example:
  /// ```dart
  /// final hasFlutter = AstHelper.hasImport(unit, 'package:flutter/material.dart');
  /// ```
  static bool hasImport(CompilationUnit unit, String importUri) {
    return getImports(unit)
        .any((import) => import.uri.stringValue == importUri);
  }

  // ========== Type and Metadata Analysis ==========

  /// Gets the superclass name of a class if it extends another class.
  ///
  /// Returns null if the class doesn't extend anything.
  static String? getSuperclassName(ClassDeclaration classDecl) {
    final extendsClause = classDecl.extendsClause;
    if (extendsClause?.superclass != null) {
      return extendsClause!.superclass.toString();
    }
    return null;
  }

  /// Checks if a method has an @override annotation.
  ///
  /// Useful for validating generated methods that should override base classes.
  static bool hasOverrideAnnotation(MethodDeclaration method) {
    return method.metadata
        .any((annotation) => annotation.name.name == 'override');
  }

  /// Gets the return type of a method as a string.
  ///
  /// Returns null for void methods or methods without explicit return types.
  static String? getMethodReturnType(MethodDeclaration method) {
    return method.returnType?.toString();
  }

  // ========== Field and Variable Analysis ==========

  /// Gets all variable names from a field declaration.
  ///
  /// A single field declaration can declare multiple variables:
  /// `String name, email, phone;` would return ['name', 'email', 'phone']
  static List<String> getFieldVariableNames(FieldDeclaration field) {
    return field.fields.variables.map((v) => v.name.lexeme).toList();
  }

  /// Gets all variable names from a variable declaration list.
  ///
  /// Similar to getFieldVariableNames but works directly with VariableDeclarationList.
  static List<String> getVariableNames(VariableDeclarationList variables) {
    return variables.variables.map((v) => v.name.lexeme).toList();
  }

  /// Checks if a field is declared as final.
  static bool isFieldFinal(FieldDeclaration field) {
    return field.fields.keyword?.lexeme == 'final';
  }

  /// Checks if a variable declaration list is declared as final.
  static bool isVariableFinal(VariableDeclarationList variables) {
    return variables.keyword?.lexeme == 'final';
  }

  /// Gets the type annotation of a field as a string.
  ///
  /// If no explicit type annotation exists, tries to infer from initializer.
  /// Returns null if no type information is available.
  static String? getFieldType(FieldDeclaration field) {
    return getVariableType(field.fields);
  }

  /// Gets the type annotation of a variable list as a string.
  ///
  /// This method tries multiple approaches:
  /// 1. Explicit type annotation (e.g., `List<String> items = [];`)
  /// 2. Type inference from typed literals (e.g., `var items = <String>[];`)
  ///
  /// Returns null if no type information can be determined.
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