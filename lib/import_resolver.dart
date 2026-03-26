import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;

class ImportResolver {
  final List<LibraryElement> libs;
  final String targetFilePath;

  const ImportResolver(this.libs, this.targetFilePath);

  String? resolve(Element? element) {
    // return early if source is null or element is a core type
    final elementSourceUri = _sourceUriOfElement(element);
    if (elementSourceUri == null || _isCoreDartType(element)) {
      return null;
    }

    for (var lib in libs) {
      if (_isCoreDartType(lib)) continue;

      if (lib.exportNamespace.definedNames2.values.contains(element)) {
        final packageSourceUri = lib.firstFragment.source.uri;
        final package = packageSourceUri.pathSegments.first;
        if (targetFilePath.startsWith(RegExp('^$package/'))) {
          return p.posix
              .relative(elementSourceUri.path, from: targetFilePath)
              .replaceFirst('../', '');
        } else {
          return elementSourceUri.toString();
        }
      }
    }

    return null;
  }

  bool _isCoreDartType(Element? element) {
    if (element == null) {
      return false;
    }
    return element is LibraryElement
        ? element.isDartCore
        : element.library?.isDartCore ?? false;
  }

  Uri? _sourceUriOfElement(Element? element) {
    return element?.firstFragment.libraryFragment?.source.uri;
  }

  Set<String> resolveAll(DartType type) {
    final imports = <String>{};
    final resolvedValue = resolve(type.element);
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
        final resolvedValue = resolve(type.element);
        if (resolvedValue != null) {
          imports.add(resolvedValue);
        }
        imports.addAll(_checkForParameterizedTypes(type));
      }
    }
    return imports;
  }
}
