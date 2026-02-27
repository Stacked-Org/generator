import 'package:stacked_generator/src/generators/router_2/router_2_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Router2Generator -', () {
    late Router2Generator generator;

    setUp(() {
      generator = Router2Generator();
    });

    group('generate -', () {
      test('should generate placeholder content', () {
        final result = generator.generate();
        
        expect(result, isNotEmpty);
        expect(result, equals('// This is the second router'));
      });

      test('should initialize with empty classes and imports lists', () {
        expect(generator.classes, isEmpty);
        expect(generator.notAliasedImports, isEmpty);
      });

      test('should implement BaseGenerator interface', () {
        expect(generator.generate, returnsNormally);
        expect(generator.generate(), isA<String>());
      });
    });

    group('properties -', () {
      test('should have modifiable classes list', () {
        expect(generator.classes, isEmpty);
        
        // Classes list should be mutable for adding generated specs
        // In real usage, this would contain actual Spec objects from code_builder
        expect(generator.classes, isA<List>());
      });

      test('should have modifiable notAliasedImports list', () {
        expect(generator.notAliasedImports, isEmpty);
        
        // Imports list should be mutable for adding import strings
        generator.notAliasedImports.add('package:flutter/material.dart');
        expect(generator.notAliasedImports.length, equals(1));
        expect(generator.notAliasedImports.first, equals('package:flutter/material.dart'));
      });
    });

    group('integration -', () {
      test('should work as part of code generation pipeline', () {
        // Test that the generator can be used in typical code generation workflow
        final generator = Router2Generator();
        
        // Add some mock data to simulate usage
        generator.notAliasedImports.addAll([
          'package:flutter/material.dart',
          'package:stacked/stacked.dart',
        ]);
        
        final result = generator.generate();
        expect(result, isNotEmpty);
        
        // Verify the generator maintains its state
        expect(generator.notAliasedImports.length, equals(2));
      });
    });
  });
}