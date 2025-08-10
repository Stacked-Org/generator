import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Core AST utilities for code generation tests.
/// Provides parsing and navigation helpers (classes, methods, fields, imports,
/// and types) used by domain validators. Focuses on semantic checks so tests
/// are resilient to formatting differences.
class AstHelper {
  /// Parse Dart source into a CompilationUnit AST.
  /// Fails the test if parsing reports any errors.
  /// Use this as the entrypoint for semantic validation.
  static CompilationUnit parseCode(String code) {
    final result = parseString(content: code);
    if (result.errors.isNotEmpty) {
      fail('Failed to parse code: ${result.errors.first}');
    }
    return result.unit;
  }

  // ========== Class and Declaration Finders ==========

  /// Find a class declaration by name; returns null if not found.
  /// Useful to locate generated classes for structural validation.
  static ClassDeclaration? findClass(CompilationUnit unit, String className) {
    return unit.declarations
        .whereType<ClassDeclaration>()
        .where((c) => c.name.lexeme == className)
        .firstOrNull;
  }

  /// Find an extension declaration by name; returns null if not found.
  static ExtensionDeclaration? findExtension(
      CompilationUnit unit, String extensionName) {
    return unit.declarations
        .whereType<ExtensionDeclaration>()
        .where((e) => e.name?.lexeme == extensionName)
        .firstOrNull;
  }

  /// Find all extension declarations in the compilation unit.
  static List<ExtensionDeclaration> findExtensions(CompilationUnit unit) {
    return unit.declarations.whereType<ExtensionDeclaration>().toList();
  }

  /// Find a top-level variable declaration by name.
  static TopLevelVariableDeclaration? findTopLevelVariableDeclaration(
      CompilationUnit unit, String variableName) {
    return unit.declarations
        .whereType<TopLevelVariableDeclaration>()
        .where((v) => v.variables.variables
            .any((variable) => variable.name.lexeme == variableName))
        .firstOrNull;
  }

  // ========== Class Member Finders ==========

  /// Return all method declarations in a class.
  static List<MethodDeclaration> findMethods(ClassDeclaration classDecl) {
    return classDecl.members.whereType<MethodDeclaration>().toList();
  }

  /// Return all field declarations in a class.
  static List<FieldDeclaration> findFields(ClassDeclaration classDecl) {
    return classDecl.members.whereType<FieldDeclaration>().toList();
  }

  /// Find a method by name in a class; returns null if not found.
  static MethodDeclaration? findMethod(
      ClassDeclaration classDecl, String methodName) {
    return findMethods(classDecl)
        .where((m) => m.name.lexeme == methodName)
        .firstOrNull;
  }

  /// Find a field (by variable name) in a class; returns null if not found.
  static FieldDeclaration? findField(
      ClassDeclaration classDecl, String fieldName) {
    return findFields(classDecl)
        .where((f) => f.fields.variables.any((v) => v.name.lexeme == fieldName))
        .firstOrNull;
  }

  /// Find a constructor by name; use class name for default constructor.
  /// Returns null when the constructor is not present.
  static ConstructorDeclaration? findConstructor(
      ClassDeclaration classDecl, String constructorName) {
    return classDecl.members
        .whereType<ConstructorDeclaration>()
        .where((c) =>
            c.name?.lexeme == constructorName ||
            (c.name == null && constructorName == classDecl.name.lexeme))
        .firstOrNull;
  }

  /// Find a method by name in an extension; returns null if not found.
  static MethodDeclaration? findMethodInExtension(
      ExtensionDeclaration extension, String methodName) {
    return extension.members
        .whereType<MethodDeclaration>()
        .where((m) => m.name.lexeme == methodName)
        .firstOrNull;
  }

  // ========== Import Analysis ==========

  /// Return all import directives from the compilation unit.
  static List<ImportDirective> getImports(CompilationUnit unit) {
    return unit.directives.whereType<ImportDirective>().toList();
  }

  /// Check if an import exists by URI string.
  static bool hasImport(CompilationUnit unit, String importUri) {
    return getImports(unit)
        .any((import) => import.uri.stringValue == importUri);
  }

  // ========== Type and Metadata Analysis ==========

  /// Get the superclass name for a class, or null if none.
  static String? getSuperclassName(ClassDeclaration classDecl) {
    final extendsClause = classDecl.extendsClause;
    if (extendsClause?.superclass != null) {
      return extendsClause!.superclass.toString();
    }
    return null;
  }

  /// Check whether a method has an @override annotation.
  static bool hasOverrideAnnotation(MethodDeclaration method) {
    return method.metadata
        .any((annotation) => annotation.name.name == 'override');
  }

  /// Get a method's return type as string, or null for void/implicit.
  static String? getMethodReturnType(MethodDeclaration method) {
    return method.returnType?.toString();
  }

  // ========== Field and Variable Analysis ==========

  /// Get variable names from a field declaration (handles multiple vars).
  static List<String> getFieldVariableNames(FieldDeclaration field) {
    return field.fields.variables.map((v) => v.name.lexeme).toList();
  }

  /// Get variable names from a VariableDeclarationList.
  static List<String> getVariableNames(VariableDeclarationList variables) {
    return variables.variables.map((v) => v.name.lexeme).toList();
  }

  /// Check if a field is declared final.
  static bool isFieldFinal(FieldDeclaration field) {
    return field.fields.keyword?.lexeme == 'final';
  }

  /// Check if a variable declaration list is declared final.
  static bool isVariableFinal(VariableDeclarationList variables) {
    return variables.keyword?.lexeme == 'final';
  }

  /// Get a field's declared type; falls back to variable list inference.
  static String? getFieldType(FieldDeclaration field) {
    return getVariableType(field.fields);
  }

  /// Get declared type of variables list, with basic inference.
  /// Tries explicit annotation, then typed literal initializers (e.g. `<T>`[]).
  /// Returns null if type cannot be determined.
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
