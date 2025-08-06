import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;

class ImportResolver {
  final List<LibraryElement2> libs;
  final String targetFilePath;

  const ImportResolver(this.libs, this.targetFilePath);

  String? resolve(Element2? element) {
    // return early if source is null or element is a core type
    if (element?.firstFragment.libraryFragment?.source == null ||
        _isCoreDartType(element)) {
      return null;
    }

    for (var lib in libs) {
      if (_isCoreDartType(lib)) continue;

      if (lib.exportNamespace.definedNames2.keys
          .contains(element?.firstFragment.name2)) {
        final package =
            lib.firstFragment.libraryFragment?.source.uri.pathSegments.first;
        if (targetFilePath.startsWith(RegExp('^$package/'))) {
          return p.posix
              .relative(
                  element?.firstFragment.libraryFragment?.source.uri.path ?? '',
                  from: targetFilePath)
              .replaceFirst('../', '');
        } else {
          return element?.firstFragment.libraryFragment?.source.uri.toString();
        }
      }
    }

    return null;
  }

  bool _isCoreDartType(Element2? element) {
    return element?.firstFragment.libraryFragment?.source.fullName ==
        'dart:core';
  }

  Set<String> resolveAll(DartType type) {
    final imports = <String>{};
    final resolvedValue = resolve(type.element3);
    if (resolvedValue != null) {
      imports.add(resolvedValue);
    }
    imports.addAll(_checkForParameterizedTypes(type));
    return imports..removeWhere((element) => element == '');
  }

  Set<String> _checkForParameterizedTypes(DartType typeToCheck) {
    final imports = <String>{};
    if (typeToCheck is ParameterizedType) {
      for (DartType type in typeToCheck.typeArguments) {
        final resolvedValue = resolve(type.element3);
        if (resolvedValue != null) {
          imports.add(resolvedValue);
        }
        imports.addAll(_checkForParameterizedTypes(type));
      }
    }
    return imports;
  }
}
