import 'package:stacked_generator/src/generators/base_generator.dart';
import 'package:stacked_generator/src/generators/extensions/list_utils_extension.dart';
import 'package:stacked_generator/src/generators/logging/logger_class_content.dart';

import 'logger_config.dart';

class LoggerBuilder with StringBufferUtils {
  final LoggerConfig loggerConfig;
  LoggerBuilder({required this.loggerConfig});

  LoggerBuilder addImports() {
    final withTestsLoggerImportsInPlace = loggerClassPrefex.replaceFirst(
      testLoggerImports,
      loggerConfig.disableTestsConsoleOutput ? '''import 'dart:io';''' : '',
    );
    write(withTestsLoggerImportsInPlace);

    writeLine();

    final sorted = loggerConfig.imports.toList()..sort();
    for (final import in sorted) {
      writeLine("import '$import';");
    }

    writeLine();
    writeLine();
    writeLine();

    return this;
  }

  LoggerBuilder addLoggerClassConstantBody() {
    write(loggerClassConstantBody);
    return this;
  }

  LoggerBuilder addLoggerNameAndOutputs() {
    final withHelperNameInPlace = loggerClassNameAndOutputs.replaceFirst(
      logHelperNameKey,
      loggerConfig.logHelperName,
    );

    String withTestVarsLoggerInPlace = withHelperNameInPlace.replaceFirst(
      disableConsoleOutputInTest,
      loggerConfig.disableTestsConsoleOutput
          ? '''
  const kForceConsoleOutput = bool.fromEnvironment('FORCE_CONSOLE_OUTPUT');
  const kIntegrationTestMode = bool.fromEnvironment('INTEGRATION_TEST_MODE');
  final kUnitTestMode = Platform.environment.containsKey('FLUTTER_TEST');
  final kTestMode = kIntegrationTestMode || kUnitTestMode;
'''
          : '',
    );

    String withConditionalLoggerInPlace =
        withTestVarsLoggerInPlace.replaceFirst(
      disableConsoleOutputInRelease,
      loggerConfig.disableReleaseConsoleOutput &&
              loggerConfig.disableTestsConsoleOutput
          ? 'if ((!kReleaseMode && !kTestMode) || kForceConsoleOutput)'
          : loggerConfig.disableReleaseConsoleOutput
              ? 'if (!kReleaseMode)'
              : loggerConfig.disableTestsConsoleOutput
                  ? 'if (!kTestMode || kForceConsoleOutput)'
                  : '',
    );

    String loggerOutputsInPlace = withConditionalLoggerInPlace.replaceFirst(
      multipleLoggerOutput,
      loggerConfig.loggerOutputs.addCheckForReleaseModeToEachLogger,
    );

    write(loggerOutputsInPlace);

    return this;
  }
}
