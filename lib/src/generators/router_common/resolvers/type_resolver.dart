import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart'
    show NullabilitySuffix;
import 'package:analyzer/dart/element/type.dart'
    show DartType, ParameterizedType;
import 'package:path/path.dart' as p;
import 'package:stacked_generator/src/generators/router_common/models/importable_type.dart';

class TypeResolver {
  final List<LibraryElement2> libs;
  final Uri? targetFile;

  TypeResolver(this.libs, [this.targetFile]);

  String? resolveImport(Element2? element) {
    // return early if source is null or element is a core type
    if (libs.isEmpty ||
        element?.firstFragment.libraryFragment?.source == null ||
        _isCoreDartType(element!)) {
      return null;
    }

    for (var lib in libs) {
      if (!_isCoreDartType(lib) &&
          lib.exportNamespace.definedNames2.values.contains(element)) {
        return targetFile == null
            ? lib.identifier
            : _relative(
                lib.firstFragment.libraryFragment?.source.uri,
                targetFile!,
              );
      }
    }
    return null;
  }

  String _relative(Uri? fileUri, Uri to) {
    var libName = to.pathSegments.first;
    if ((to.scheme == 'package' &&
            fileUri?.scheme == 'package' &&
            fileUri?.pathSegments.first == libName) ||
        (to.scheme == 'asset' && fileUri?.scheme != 'package')) {
      if (fileUri?.path == to.path) {
        return fileUri?.pathSegments.last ?? '';
      } else {
        return p.posix
            .relative(fileUri?.path ?? '', from: to.path)
            .replaceFirst('../', '');
      }
    } else {
      return fileUri.toString();
    }
  }

  bool _isCoreDartType(Element2 element) {
    return element.firstFragment.libraryFragment?.source.fullName ==
        'dart:core';
  }

  List<ResolvedType> _resolveTypeArguments(DartType typeToCheck) {
    final types = <ResolvedType>[];
    if (typeToCheck is ParameterizedType) {
      for (DartType type in typeToCheck.typeArguments) {
        if (type.element3 is TypeParameterElement2) {
          types.add(ResolvedType(name: 'dynamic'));
        } else {
          types.add(ResolvedType(
            name: type.element3?.name3 ?? 'void',
            import: resolveImport(type.element3),
            isNullable: type.nullabilitySuffix == NullabilitySuffix.question,
            typeArguments: _resolveTypeArguments(type),
          ));
        }
      }
    }
    return types;
  }

  ResolvedType resolveFunctionType(ExecutableElement2 function) {
    final displayName = function.displayName.replaceFirst(RegExp('^_'), '');
    var functionName = displayName;
    Element2? elementToImport = function;
    if (function.enclosingElement2 is ClassElement2) {
      functionName = '${function.enclosingElement2?.displayName}.$displayName';
      elementToImport = function.enclosingElement2;
    }
    return ResolvedType(
      name: functionName,
      import: resolveImport(elementToImport),
    );
  }

  ResolvedType resolveType(DartType type) {
    return ResolvedType(
      name: type.element3?.name3 ?? type.getDisplayString(),
      isNullable: type.nullabilitySuffix == NullabilitySuffix.question,
      import: resolveImport(type.element3),
      typeArguments: _resolveTypeArguments(type),
    );
  }
}
