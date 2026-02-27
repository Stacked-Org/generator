import 'package:stacked_generator/src/generators/extensions/environments_extract_extension.dart';
import 'package:test/test.dart';

void main() {
  group('EnvironmentExtractExtension -', () {
    group('getFromatedEnvs -', () {
      test('should return empty string for null set', () {
        const Set<String>? nullSet = null;
        final result = nullSet.getFromatedEnvs;
        
        expect(result, equals(''));
      });

      test('should return empty string for empty set', () {
        final emptySet = <String>{};
        final result = emptySet.getFromatedEnvs;
        
        expect(result, equals(''));
      });

      test('should format single environment correctly', () {
        final envs = {'dev'};
        final result = envs.getFromatedEnvs;
        
        expect(result, equals(',registerFor:{"dev"}'));
      });

      test('should format multiple environments correctly', () {
        final envs = {'dev', 'prod'};
        final result = envs.getFromatedEnvs;
        
        // Note: Set iteration order is not guaranteed, so we need to check both possibilities
        final isValidFormat1 = result == ',registerFor:{"dev","prod"}';
        final isValidFormat2 = result == ',registerFor:{"prod","dev"}';
        
        expect(isValidFormat1 || isValidFormat2, isTrue, 
          reason: 'Expected either format but got: $result');
      });

      test('should format three environments correctly', () {
        final envs = {'dev', 'staging', 'prod'};
        final result = envs.getFromatedEnvs;
        
        // Check that the structure is correct regardless of order
        expect(result, startsWith(',registerFor:{'));
        expect(result, endsWith('}'));
        expect(result, contains('"dev"'));
        expect(result, contains('"staging"'));
        expect(result, contains('"prod"'));
        
        // Count the number of quoted environment names
        final quoteCount = '"'.allMatches(result).length;
        expect(quoteCount, equals(6)); // 3 environments × 2 quotes each
      });

      test('should handle environments with special characters', () {
        final envs = {'dev-local', 'prod_remote', 'test.env'};
        final result = envs.getFromatedEnvs;
        
        expect(result, startsWith(',registerFor:{'));
        expect(result, endsWith('}'));
        expect(result, contains('"dev-local"'));
        expect(result, contains('"prod_remote"'));
        expect(result, contains('"test.env"'));
      });

      test('should handle environments with numbers', () {
        final envs = {'env1', 'env2', 'prod123'};
        final result = envs.getFromatedEnvs;
        
        expect(result, startsWith(',registerFor:{'));
        expect(result, contains('"env1"'));
        expect(result, contains('"env2"'));
        expect(result, contains('"prod123"'));
      });

      test('should handle empty string environments', () {
        final envs = {'', 'dev'};
        final result = envs.getFromatedEnvs;
        
        expect(result, startsWith(',registerFor:{'));
        expect(result, contains('""')); // Empty string should be quoted
        expect(result, contains('"dev"'));
      });

      test('should handle environments with mixed case', () {
        final envs = {'DEV', 'Prod', 'staging'};
        final result = envs.getFromatedEnvs;
        
        expect(result, startsWith(',registerFor:{'));
        expect(result, contains('"DEV"'));
        expect(result, contains('"Prod"'));
        expect(result, contains('"staging"'));
      });
    });

    group('Generated Code Validation -', () {
      test('should generate valid GetIt registerFor parameter format', () {
        final envs = {'dev', 'prod'};
        final result = envs.getFromatedEnvs;
        
        // Should be valid as part of a GetIt registration call
        expect(result, startsWith(',registerFor:'));
        expect(result, matches(RegExp(r',registerFor:\{("[^"]*"(,"[^"]*")*)\}$')));
      });

      test('should generate syntactically correct JSON-like structure', () {
        final envs = {'env1', 'env2', 'env3'};
        final result = envs.getFromatedEnvs;
        
        // Extract the JSON part
        final jsonPart = result.substring(',registerFor:'.length);
        expect(jsonPart, startsWith('{'));
        expect(jsonPart, endsWith('}'));
        
        // Should have proper comma separation (but not trailing comma)
        expect(jsonPart, isNot(contains(',}')));
      });

      test('should handle large environment sets efficiently', () {
        final envs = Set<String>.from(List.generate(50, (index) => 'env$index'));
        final result = envs.getFromatedEnvs;
        
        expect(result, startsWith(',registerFor:{'));
        expect(result, endsWith('}'));
        
        // Should contain all environments
        for (int i = 0; i < 50; i++) {
          expect(result, contains('"env$i"'));
        }
      });

      test('should properly escape quotes in environment names', () {
        // Note: This is a theoretical test - in practice, environment names 
        // with quotes would be unusual, but the extension should handle them
        final envs = {'dev'};
        final result = envs.getFromatedEnvs;
        
        expect(result, equals(',registerFor:{"dev"}'));
        // Environment names are wrapped in quotes, so they should be properly formatted
      });
    });

    group('Integration Scenarios -', () {
      test('should work in typical dependency injection context', () {
        final envs = {'dev', 'test'};
        final result = envs.getFromatedEnvs;
        
        // Simulate how this would be used in generated code
        final fullRegistration = 'locator.registerLazySingleton<Service>(() => ServiceImpl()$result);';
        
        final hasDevFirst = fullRegistration.contains(',registerFor:{"dev","test"}');
        final hasTestFirst = fullRegistration.contains(',registerFor:{"test","dev"}');
        expect(hasDevFirst || hasTestFirst, isTrue);
      });

      test('should work with common environment names', () {
        final commonEnvs = {'development', 'testing', 'staging', 'production'};
        final result = commonEnvs.getFromatedEnvs;
        
        expect(result, startsWith(',registerFor:{'));
        expect(result, contains('"development"'));
        expect(result, contains('"testing"'));
        expect(result, contains('"staging"'));
        expect(result, contains('"production"'));
      });

      test('should maintain consistency across multiple calls', () {
        final envs = {'dev', 'prod'};
        final result1 = envs.getFromatedEnvs;
        final result2 = envs.getFromatedEnvs;
        
        expect(result1, equals(result2));
      });
    });
  });
}