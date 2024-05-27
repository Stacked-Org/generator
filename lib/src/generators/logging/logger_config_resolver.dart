import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:stacked_generator/import_resolver.dart';
import 'package:stacked_generator/src/generators/logging/logger_config.dart';

/// Resolves the [LoggerConfig] and returns the object if it's supplied
class LoggerConfigResolver {
  Future<LoggerConfig?> resolve(
    ConstantReader stackedApp,
    ImportResolver importResolver,
  ) async {
    final loggerReader = stackedApp.peek('logger');
    final multiLogger = loggerReader?.peek('loggerOutputs')?.listValue;
    final logHelperName =
        loggerReader?.peek('logHelperName')?.stringValue ?? 'getLogger';

    final disableReleaseConsoleOutput =
        loggerReader?.peek('disableReleaseConsoleOutput')?.boolValue ?? true;

    final disableTestsConsoleOutput =
        loggerReader?.peek('disableTestsConsoleOutput')?.boolValue ?? false;

    if (loggerReader != null) {
      return LoggerConfig(
        logHelperName: logHelperName,
        imports: _resolveImports(
          importResolver: importResolver,
          multiLogger: multiLogger,
        ),
        loggerOutputs: _resolveMultiLogger(multiLogger),
        disableReleaseConsoleOutput: disableReleaseConsoleOutput,
        disableTestsConsoleOutput: disableTestsConsoleOutput,
      );
    }

    return null;
  }

  List<String> _resolveMultiLogger(List<DartObject>? multiLogger) {
    if (multiLogger != null) {
      return multiLogger
          .map((e) => e.toTypeValue()?.getDisplayString(withNullability: false))
          .where((element) => element != null)
          .toList()
          .cast<String>();
    } else {
      return [];
    }
  }

  Set<String> _resolveImports({
    List<DartObject>? multiLogger,
    required ImportResolver importResolver,
  }) {
    if (multiLogger != null) {
      return multiLogger
          .where((element) => element.toTypeValue() != null)
          .map((e) => importResolver.resolve(_dartOjectToElemet(e)))
          .toSet()
          .cast<String>();
    } else {
      return {};
    }
  }

  ClassElement _dartOjectToElemet(DartObject obj) {
    var dependencyReader = ConstantReader(obj).typeValue;
    return dependencyReader.element as ClassElement;
  }
}
