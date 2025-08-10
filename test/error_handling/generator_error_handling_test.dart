import 'package:stacked_generator/src/generators/exceptions/config_file_not_found_exception.dart';
import 'package:stacked_generator/src/generators/exceptions/invalid_generator_input_exception.dart';
import 'package:test/test.dart';

void main() {
  group('Generator Error Handling Tests -', () {
    group('ConfigFileNotFoundException -', () {
      test('should create exception with message', () {
        const message = 'Config file not found at path';
        final exception = ConfigFileNotFoundException(message);

        expect(exception.message, equals(message));
        expect(exception.shouldHaltCommand, isFalse);
        expect(exception.toString(), contains(message));
      });

      test('should create exception with halt command flag', () {
        const message = 'Critical config error';
        final exception = ConfigFileNotFoundException(
          message,
          shouldHaltCommand: true,
        );

        expect(exception.message, equals(message));
        expect(exception.shouldHaltCommand, isTrue);
      });

      test('should handle empty message', () {
        const message = '';
        final exception = ConfigFileNotFoundException(message);

        expect(exception.message, equals(message));
        expect(exception.toString(), isEmpty); // toString() returns message directly
      });

      test('should handle null-like message', () {
        const message = 'null';
        final exception = ConfigFileNotFoundException(message);

        expect(exception.message, equals(message));
        expect(exception.toString(), contains('null'));
      });
    });

    group('InvalidGeneratorInputException -', () {
      test('should create exception with required parameters', () {
        const message = 'Invalid input provided';
        const todo = 'Fix the input parameter';
        final exception = InvalidGeneratorInputException(
          message,
          todo: todo,
        );

        expect(exception.message, equals(message));
        expect(exception.todo, equals(todo));
        expect(exception.element, isNull);
        expect(exception.toString(), contains(message));
        expect(exception.toString(), contains(todo));
      });

      test('should create exception with element information', () {
        const message = 'Element validation failed';
        const todo = 'Check element type';
        
        final exception = InvalidGeneratorInputException(
          message,
          todo: todo,
          element: null, // Element2 type not easily mockable in tests
        );

        expect(exception.message, equals(message));
        expect(exception.todo, equals(todo));
        expect(exception.element, isNull);
        expect(exception.toString(), contains(message));
      });

      test('should handle empty strings', () {
        final exception = InvalidGeneratorInputException(
          '',
          todo: '',
        );

        expect(exception.message, isEmpty);
        expect(exception.todo, isEmpty);
        expect(exception.toString(), contains('InvalidGeneratorInputException')); // Should have class name
      });

      test('should handle special characters in message', () {
        const message = 'Error: \$special chars & symbols!';
        const todo = 'Fix @param validation';
        
        final exception = InvalidGeneratorInputException(
          message,
          todo: todo,
        );

        expect(exception.message, equals(message));
        expect(exception.todo, equals(todo));
        expect(exception.toString(), contains('special'));
        expect(exception.toString(), contains('&'));
      });

      test('should handle very long messages', () {
        final longMessage = 'A' * 1000;
        const todo = 'Handle long messages properly';
        
        final exception = InvalidGeneratorInputException(
          longMessage,
          todo: todo,
        );

        expect(exception.message, equals(longMessage));
        expect(exception.message.length, equals(1000));
        expect(exception.toString(), contains(longMessage));
      });

      test('should handle unicode characters', () {
        const message = '错误: Unicode characters in error 🚨';
        const todo = 'Support internationalization';
        
        final exception = InvalidGeneratorInputException(
          message,
          todo: todo,
        );

        expect(exception.message, equals(message));
        expect(exception.todo, equals(todo));
        expect(exception.toString(), contains('错误'));
        expect(exception.toString(), contains('🚨'));
      });
    });

    group('Exception Inheritance -', () {
      test('ConfigFileNotFoundException should extend Exception', () {
        final exception = ConfigFileNotFoundException('test');
        expect(exception, isA<Exception>());
      });

      test('InvalidGeneratorInputException should extend Exception', () {
        final exception = InvalidGeneratorInputException(
          'test',
          todo: 'test',
        );
        expect(exception, isA<Exception>());
      });

      test('exceptions should be throwable', () {
        expect(
          () => throw ConfigFileNotFoundException('test error'),
          throwsA(isA<ConfigFileNotFoundException>()),
        );

        expect(
          () => throw InvalidGeneratorInputException(
            'test error',
            todo: 'fix it',
          ),
          throwsA(isA<InvalidGeneratorInputException>()),
        );
      });
    });

    group('Exception Serialization -', () {
      test('ConfigFileNotFoundException toString should be informative', () {
        const message = 'Config file missing';
        final exception = ConfigFileNotFoundException(message);
        final stringRepresentation = exception.toString();

        expect(stringRepresentation, isNotEmpty);
        expect(stringRepresentation, contains(message));
        // ConfigFileNotFoundException.toString() only returns message, not class name
        expect(stringRepresentation, equals(message));
      });

      test('InvalidGeneratorInputException toString should include all info', () {
        const message = 'Invalid parameter';
        const todo = 'Validate input';
        
        final exception = InvalidGeneratorInputException(
          message,
          todo: todo,
          element: null, // Element2 type not easily mockable in tests
        );
        final stringRepresentation = exception.toString();

        expect(stringRepresentation, contains(message));
        expect(stringRepresentation, contains(todo));
        expect(stringRepresentation, contains('null')); // element will be null
      });

      test('exceptions should have consistent formatting', () {
        final configException = ConfigFileNotFoundException('Config error');
        final inputException = InvalidGeneratorInputException(
          'Input error',
          todo: 'Fix input',
        );

        final configString = configException.toString();
        final inputString = inputException.toString();

        // Check that they have different formats (config returns message only, input includes class name)
        expect(configString, equals('Config error')); // ConfigFileNotFoundException returns message only
        expect(inputString.contains('InvalidGeneratorInputException'), isTrue);
        
        // Should not be identical (different exception types)
        expect(configString, isNot(equals(inputString)));
      });
    });

    group('Exception Usage Patterns -', () {
      test('should support exception catching patterns', () {
        try {
          throw ConfigFileNotFoundException('test');
        } on ConfigFileNotFoundException catch (e) {
          expect(e.message, equals('test'));
          expect(e.shouldHaltCommand, isFalse);
        }
      });

      test('should support generic exception catching', () {
        try {
          throw InvalidGeneratorInputException(
            'test error',
            todo: 'fix it',
          );
        } on Exception catch (e) {
          expect(e, isA<InvalidGeneratorInputException>());
          final specificException = e as InvalidGeneratorInputException;
          expect(specificException.message, equals('test error'));
        }
      });

      test('should work with Future.catchError', () async {
        final future = Future<void>.error(
          InvalidGeneratorInputException(
            'async error',
            todo: 'handle async',
          ),
        );

        await expectLater(
          future,
          throwsA(isA<InvalidGeneratorInputException>()),
        );
      });

      test('should work in complex error handling scenarios', () {
        Exception? caughtException;
        
        try {
          try {
            throw InvalidGeneratorInputException(
              'nested error',
              todo: 'handle nesting',
            );
          } on InvalidGeneratorInputException catch (e) {
            // Rethrow as different exception type
            throw ConfigFileNotFoundException(
              'Config error caused by: ${e.message}',
            );
          }
        } on Exception catch (e) {
          caughtException = e;
        }

        expect(caughtException, isA<ConfigFileNotFoundException>());
        final configException = caughtException as ConfigFileNotFoundException;
        expect(configException.message, contains('nested error'));
      });
    });

    group('Edge Cases -', () {
      test('should handle null values gracefully', () {
        // Note: In real usage, these would be caught by null safety
        // but we test the behavior if somehow nulls get through
        
        expect(
          () => InvalidGeneratorInputException(
            'test',
            todo: 'test',
            element: null,
          ),
          returnsNormally,
        );
      });

      test('should handle extremely long error chains', () {
        var exception = InvalidGeneratorInputException(
          'Initial error',
          todo: 'Start chain',
        );

        // Simulate a chain of errors
        for (int i = 0; i < 10; i++) {
          try {
            throw exception;
          } on InvalidGeneratorInputException catch (e) {
            exception = InvalidGeneratorInputException(
              'Chain error $i: ${e.message}',
              todo: 'Handle chain $i',
            );
          }
        }

        expect(exception.message, contains('Chain error 9'));
        expect(exception.message, contains('Initial error'));
      });

      test('should handle concurrent exception creation', () async {
        final futures = List.generate(100, (index) {
          return Future(() {
            return InvalidGeneratorInputException(
              'Concurrent error $index',
              todo: 'Handle concurrent $index',
            );
          });
        });

        final exceptions = await Future.wait(futures);
        
        expect(exceptions.length, equals(100));
        
        for (int i = 0; i < exceptions.length; i++) {
          expect(exceptions[i].message, contains('Concurrent error $i'));
        }
      });
    });
  });
}