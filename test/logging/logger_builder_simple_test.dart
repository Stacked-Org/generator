import 'package:stacked_generator/src/generators/logging/logger_builder.dart';
import 'package:stacked_generator/src/generators/logging/logger_config.dart';
import 'package:test/test.dart';

void main() {
  group('LoggerBuilder Simple Tests -', () {
    test('should initialize and generate basic logger code', () {
      final loggerBuilder = LoggerBuilder(loggerConfig: LoggerConfig());
      loggerBuilder.addLoggerClassConstantBody();
      
      final generatedCode = loggerBuilder.serializeStringBuffer;
      
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('class SimpleLogPrinter'));
      expect(generatedCode, contains('LogEvent'));
      expect(generatedCode, contains('log('));
    });
    
    test('should generate logger with expected structure', () {
      final loggerBuilder = LoggerBuilder(loggerConfig: LoggerConfig());
      loggerBuilder.addLoggerClassConstantBody();
      
      final generatedCode = loggerBuilder.serializeStringBuffer;
      
      // Basic structure checks
      expect(generatedCode, contains('extends LogPrinter'));
      expect(generatedCode, contains('className'));
      expect(generatedCode, contains('@override'));
      expect(generatedCode, contains('List<String> log(LogEvent event)'));
    });
    
    test('should generate logger with error handling capabilities', () {
      final loggerBuilder = LoggerBuilder(loggerConfig: LoggerConfig());
      loggerBuilder.addLoggerClassConstantBody();
      
      final generatedCode = loggerBuilder.serializeStringBuffer;
      
      // Error handling checks
      expect(generatedCode, contains('error'));
      expect(generatedCode, contains('ERROR:'));
    });
    
    test('should generate logger with stacktrace support', () {
      final loggerBuilder = LoggerBuilder(loggerConfig: LoggerConfig());
      loggerBuilder.addLoggerClassConstantBody();
      
      final generatedCode = loggerBuilder.serializeStringBuffer;
      
      // Stacktrace checks  
      expect(generatedCode, anyOf(contains('stackTrace'), contains('STACKTRACE')));
      expect(generatedCode, contains('printCallStack'));
    });
    
    test('should support method chaining', () {
      final loggerBuilder = LoggerBuilder(loggerConfig: LoggerConfig());
      final result = loggerBuilder.addLoggerClassConstantBody();
      
      expect(result, isA<LoggerBuilder>());
      expect(result, same(loggerBuilder));
    });
    
    test('should be deterministic', () {
      final builder1 = LoggerBuilder(loggerConfig: LoggerConfig());
      builder1.addLoggerClassConstantBody();
      final code1 = builder1.serializeStringBuffer;
      
      final builder2 = LoggerBuilder(loggerConfig: LoggerConfig());
      builder2.addLoggerClassConstantBody();
      final code2 = builder2.serializeStringBuffer;
      
      expect(code1, equals(code2));
    });
  });
}