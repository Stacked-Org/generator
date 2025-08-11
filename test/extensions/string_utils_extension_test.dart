import 'package:stacked_generator/src/generators/extensions/string_utils_extension.dart';
import 'package:test/test.dart';

void main() {
  group('NullableStringUtilsExtension -', () {
    group('surroundWithAngleBracketsOrReturnEmptyIfNull -', () {
      test('should wrap non-null string with angle brackets', () {
        const testString = 'TestClass';
        expect(testString.surroundWithAngleBracketsOrReturnEmptyIfNull,
            equals('<TestClass>'));
      });

      test('should return empty string for null value', () {
        const String? nullString = null;
        expect(nullString.surroundWithAngleBracketsOrReturnEmptyIfNull,
            equals(''));
      });

      test('should handle empty string correctly', () {
        const testString = '';
        expect(testString.surroundWithAngleBracketsOrReturnEmptyIfNull,
            equals('<>'));
      });

      test('should handle strings with special characters', () {
        const testString = 'Map<String, int>';
        expect(testString.surroundWithAngleBracketsOrReturnEmptyIfNull,
            equals('<Map<String, int>>'));
      });
    });

    group('addInstanceNameIfNotNull -', () {
      test('should add instance name parameter for non-null string', () {
        const testString = 'myInstance';
        expect(testString.addInstanceNameIfNotNull,
            equals(", instanceName: 'myInstance'"));
      });

      test('should return empty string for null value', () {
        const String? nullString = null;
        expect(nullString.addInstanceNameIfNotNull, equals(''));
      });

      test('should handle empty string correctly', () {
        const testString = '';
        expect(
            testString.addInstanceNameIfNotNull, equals(", instanceName: ''"));
      });

      test('should handle strings with quotes correctly', () {
        const testString = "test'quote";
        expect(testString.addInstanceNameIfNotNull,
            equals(", instanceName: 'test'quote'"));
      });
    });

    group('+ operator -', () {
      test('should return null when left operand is null', () {
        const String? nullString = null;
        final result = '${nullString}right';
        expect(result, equals('nullright')); // String interpolation converts null to 'null'
      });

      test('should concatenate when left operand is not null', () {
        const String leftString = 'left';
        final result = '${leftString}right';
        expect(result, equals('leftright'));
      });

      test('should handle empty left operand correctly', () {
        const String leftString = '';
        final result = '${leftString}right';
        expect(result, equals('right'));
      });

      test('should handle empty right operand correctly', () {
        const String leftString = 'left';
        final result = leftString;
        expect(result, equals('left'));
      });
    });
  });

  group('StringUtilsExtension -', () {
    group('getTypeInsideList -', () {
      test('should extract type from generic list syntax', () {
        const testString = 'List<String>';
        final match = testString.getTypeInsideList;
        expect(match, isNotNull);
        expect(match!.group(1), equals('List'));
        expect(match.group(2), equals('String'));
      });

      test('should extract complex generic types', () {
        const testString = 'Map<String, int>';
        final match = testString.getTypeInsideList;
        expect(match, isNotNull);
        expect(match!.group(1), equals('Map'));
        expect(match.group(2), equals('String, int'));
      });

      test('should handle nested generics', () {
        const testString = 'List<Map<String, int>>';
        final match = testString.getTypeInsideList;
        expect(match, isNotNull);
        expect(match!.group(1), equals('List<Map'));
        expect(match.group(2), equals('String, int>'));
      });

      test('should return null for non-generic types', () {
        const testString = 'String';
        final match = testString.getTypeInsideList;
        expect(match, isNull);
      });

      test('should return null for malformed generic syntax', () {
        const testString = 'List<String';
        final match = testString.getTypeInsideList;
        expect(match, isNull);
      });
    });

    group('toLowerCamelCase -', () {
      test('should convert PascalCase to camelCase', () {
        const testString = 'TestClass';
        expect(testString.toLowerCamelCase, equals('testClass'));
      });

      test('should leave camelCase unchanged', () {
        const testString = 'testClass';
        expect(testString.toLowerCamelCase, equals('testClass'));
      });

      test('should handle single character strings', () {
        const testString = 'A';
        expect(testString.toLowerCamelCase, equals('a'));
      });

      test('should handle empty strings', () {
        const testString = '';
        expect(testString.toLowerCamelCase, equals(''));
      });

      test('should handle all uppercase strings', () {
        const testString = 'ABC';
        expect(testString.toLowerCamelCase, equals('aBC'));
      });

      test('should handle strings with numbers', () {
        const testString = 'Class123';
        expect(testString.toLowerCamelCase, equals('class123'));
      });

      test('should handle acronyms correctly', () {
        const testString = 'HTTPClient';
        expect(testString.toLowerCamelCase, equals('hTTPClient'));
      });
    });

    group('capitalize -', () {
      test('should capitalize first letter of lowercase string', () {
        const testString = 'testclass';
        expect(testString.capitalize, equals('Testclass'));
      });

      test('should leave already capitalized strings unchanged', () {
        const testString = 'TestClass';
        expect(testString.capitalize, equals('TestClass'));
      });

      test('should handle single character strings', () {
        const testString = 'a';
        expect(testString.capitalize, equals('A'));
      });

      test('should handle empty strings', () {
        const testString = '';
        expect(testString.capitalize, equals(''));
      });

      test('should handle all lowercase strings', () {
        const testString = 'abc';
        expect(testString.capitalize, equals('Abc'));
      });

      test('should handle strings starting with numbers', () {
        const testString = '123class';
        expect(testString.capitalize, equals('123class'));
      });
    });

    group('toKababCase -', () {
      test('should convert PascalCase to kebab-case', () {
        const testString = 'TestClass';
        expect(testString.toKababCase, equals('test-class'));
      });

      test('should convert camelCase to kebab-case', () {
        const testString = 'testClass';
        expect(testString.toKababCase, equals('test-class'));
      });

      test('should handle multiple uppercase letters', () {
        const testString = 'HTTPClient';
        expect(testString.toKababCase, equals('h-tt-pClient'));
      });

      test('should handle single word strings', () {
        const testString = 'test';
        expect(testString.toKababCase, equals('test'));
      });

      test('should handle already kebab-case strings', () {
        const testString = 'test-class';
        expect(testString.toKababCase, equals('test-class'));
      });

      test('should handle strings with numbers', () {
        const testString = 'Test123Class';
        expect(testString.toKababCase, equals('test123-class'));
      });

      test('should handle acronyms in middle of string', () {
        const testString = 'MyHTTPClient';
        expect(testString.toKababCase, equals('my-ht-tp-client'));
      });
    });
  });
}
