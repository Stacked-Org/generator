import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

final throwsCompileError = throwsA(isA<CompileError>());

Future<void> compile(String src) async {
  final main = await resolveSources({
    'freezed|test/integration/main.dart': '''
library main;

$src
    ''',
  }, (r) => r.findLibraryByName('main'));

  final errorResult = await main!.session
          .getErrors('/stacked_generator/test/integration/main.dart')
      as ErrorsResult;
  final criticalErrors = errorResult.errors
      .where((element) => element.severity == Severity.error)
      .toList();

  if (criticalErrors.isNotEmpty) {
    throw CompileError(criticalErrors);
  }
}

class CompileError extends Error {
  CompileError(this.errors);
  final List<AnalysisError> errors;

  @override
  String toString() {
    return 'CompileError: \n${errors.join('\n')}';
  }
}

Future<void> checkCodeForCompilationError(
    {required String generatorName,
    required String relativePath,
    required String fileName}) async {
  final main = await resolveSources(
    {
      '$generatorName|$relativePath$fileName.dart': useAssetReader,
    },
    (r) => r.libraries.firstWhere(
      (element) {
        /// [element.firstFragment.libraryFragment.source.toString()] will print the name of the file for example 'test.dart'
        return element.firstFragment.libraryFragment!.source
            .toString()
            .contains(fileName);
      },
    ),
    readAllSourcesFromFilesystem: true,
  );

  final errorResult = await main.session
      .getErrors('/$generatorName/$relativePath$fileName.dart') as ErrorsResult;

  expect(errorResult.errors, isEmpty);
}
