import 'package:stacked_generator/src/generators/extensions/list_utils_extension.dart';
import 'package:test/test.dart';

void main() {
  group('LoggerClassGeneratorExtension -', () {
    group('addCheckForReleaseModeToEachLogger -', () {
      test('should wrap single logger with kReleaseMode check', () {
        final loggers = ['consoleLogger'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) consoleLogger(),'));
      });

      test('should wrap multiple loggers with kReleaseMode checks', () {
        final loggers = ['consoleLogger', 'fileLogger', 'networkLogger'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) consoleLogger(), if(kReleaseMode) fileLogger(), if(kReleaseMode) networkLogger(),'));
      });

      test('should handle empty logger list', () {
        final loggers = <String>[];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(''));
      });

      test('should handle logger names with special characters', () {
        final loggers = ['console_logger', 'file-logger', 'logger123'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) console_logger(), if(kReleaseMode) file-logger(), if(kReleaseMode) logger123(),'));
      });

      test('should handle logger names with different casing', () {
        final loggers = ['ConsoleLogger', 'FILE_LOGGER', 'mixedCaseLogger'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) ConsoleLogger(), if(kReleaseMode) FILE_LOGGER(), if(kReleaseMode) mixedCaseLogger(),'));
      });

      test('should generate properly formatted conditional statements', () {
        final loggers = ['logger1', 'logger2'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        // Verify the format is correct for dart code generation
        expect(result, startsWith(' if(kReleaseMode)'));
        expect(result, contains('(),'));
        expect(result.split('if(kReleaseMode)').length - 1, equals(2)); // Two loggers = two conditions
      });

      test('should maintain order of loggers', () {
        final loggers = ['firstLogger', 'secondLogger', 'thirdLogger'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        final expectedOrder = ' if(kReleaseMode) firstLogger(), if(kReleaseMode) secondLogger(), if(kReleaseMode) thirdLogger(),';
        expect(result, equals(expectedOrder));
      });

      test('should handle single character logger names', () {
        final loggers = ['a', 'b', 'c'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) a(), if(kReleaseMode) b(), if(kReleaseMode) c(),'));
      });

      test('should handle very long logger names', () {
        final loggers = ['veryLongLoggerNameThatExceedsNormalLengthExpectations'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) veryLongLoggerNameThatExceedsNormalLengthExpectations(),'));
      });

      test('should handle logger names with numbers', () {
        final loggers = ['logger1', 'logger2', 'logger123'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) logger1(), if(kReleaseMode) logger2(), if(kReleaseMode) logger123(),'));
      });
    });

    group('Edge Cases -', () {
      test('should handle list with null-like string names', () {
        final loggers = ['null', 'undefined', ''];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) null(), if(kReleaseMode) undefined(), if(kReleaseMode) (),'));
      });

      test('should handle large lists efficiently', () {
        final loggers = List.generate(100, (index) => 'logger$index');
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result.split('if(kReleaseMode)').length - 1, equals(100));
        expect(result, startsWith(' if(kReleaseMode) logger0(),'));
        expect(result, endsWith(' if(kReleaseMode) logger99(),'));
      });

      test('should handle list with duplicate logger names', () {
        final loggers = ['duplicateLogger', 'duplicateLogger', 'uniqueLogger'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        expect(result, equals(' if(kReleaseMode) duplicateLogger(), if(kReleaseMode) duplicateLogger(), if(kReleaseMode) uniqueLogger(),'));
      });
    });

    group('Generated Code Validation -', () {
      test('generated code should be syntactically correct dart', () {
        final loggers = ['logger1', 'logger2'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        // Check that the generated code follows Dart syntax rules
        expect(result, matches(RegExp(r'^( if\(kReleaseMode\) \w+\(\),)*$')));
      });

      test('should generate code compatible with conditional compilation', () {
        final loggers = ['logger'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        // Ensure kReleaseMode is used correctly for Flutter conditional compilation
        expect(result, contains('if(kReleaseMode)'));
        expect(result, contains('logger()'));
      });

      test('should generate code that can be embedded in larger statements', () {
        final loggers = ['logger'];
        final result = loggers.addCheckForReleaseModeToEachLogger;
        
        // Should be embeddable in larger code structures (notice trailing comma)
        expect(result, endsWith(','));
        expect(result, startsWith(' ')); // Proper spacing for embedding
      });
    });
  });
}