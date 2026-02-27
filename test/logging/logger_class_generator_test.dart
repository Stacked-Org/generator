import 'package:stacked_generator/src/generators/logging/logger_class_generator.dart';
import 'package:stacked_generator/src/generators/logging/logger_config.dart';
import 'package:test/test.dart';

import '../helpers/ast/logger_ast_validators.dart';

void main() {
  group('LoggerClassGeneratorTest -', () {
    group('generate -', () {
      test('Given this LoggerConfig, Should predict the output', () async {
        final loggerConfig = LoggerConfig(
            imports: {'importOne', 'importTwo'},
            logHelperName: 'ebraLogger',
            loggerOutputs: ['outputOne', 'outputTwo']);
        final generatedCode = LoggerClassGenerator(loggerConfig).generate();
        
        // AST-based validation instead of string comparison
        LoggerClassGeneratorAstValidator.validateLoggerGeneration(
          generatedCode,
          expectedConfig: loggerConfig,
        );
      });
      test(
          'Given a LoggerConfig with disableReleaseConsoleOutput=false, Should predict the output',
          () async {
        final loggerConfig = LoggerConfig(
            disableReleaseConsoleOutput: false,
            imports: {'importOne', 'importTwo'},
            logHelperName: 'ebraLogger',
            loggerOutputs: ['outputOne', 'outputTwo']);
        final generatedCode = LoggerClassGenerator(loggerConfig).generate();
        
        // AST-based validation instead of string comparison
        LoggerClassGeneratorAstValidator.validateLoggerGeneration(
          generatedCode,
          expectedConfig: loggerConfig,
        );
      });
    });
  });
}
