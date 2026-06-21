import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;
import 'package:stacked_generator/utils.dart';

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

    // No library in `libs` re-exports `element`. This can happen under
    // build systems whose codegen resolvers expose a narrower library set
    // than build_runner does — e.g. Bazel's rules_dart codegen action,
    // which provides each transitive package's `src/` libraries but not
    // their public re-exporting library. Without this fallback, callers
    // (e.g. dependency_config_factory) end up emitting `import null;` for
    // perfectly reachable types like StackedService.
    //
    // The element's own source URI is always a valid Dart import — it
    // just points at a `src/` path rather than the public re-export.
    // Generated code compiles and behaves identically. Prefer this over
    // returning null, which strands the caller with no recoverable info.
    return elementSourceUri.toString();
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
    return elementSourceUri(element);
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
