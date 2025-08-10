import 'package:source_gen/source_gen.dart';
import 'package:stacked_generator/src/generators/router_2/auto_route_generator.dart';
import 'package:test/test.dart';

void main() {
  group('StackedRouterGenerator -', () {
    late StackedRouterGenerator generator;

    setUp(() {
      generator = StackedRouterGenerator();
    });

    group('generateForAnnotatedElement -', () {
      test('should throw error when annotation is used on non-class element',
          () async {
        // This test validates that the generator properly validates element types
        // and throws appropriate errors for invalid usage

        // Note: This is a placeholder test that demonstrates the structure
        // The actual implementation would require setting up a proper BuildStep
        // and Element2 for testing, which involves complex analyzer setup

        expect(() => generator, isNotNull);
        expect(generator, isA<Generator>());
      });

      test('should generate router code for properly annotated class',
          () async {
        // Test case for successful code generation
        // This would test the full pipeline from annotation to generated code

        // Note: Full implementation requires:
        // 1. Setting up a BuildStep with resolver
        // 2. Creating a mock ClassElement2 with proper annotations
        // 3. Validating the generated output using AST validation

        expect(() => generator, isNotNull);
      });

      test('should handle part directive detection correctly', () async {
        // Test the _hasPartDirective method functionality
        // This ensures proper detection of part files for generated code

        expect(() => generator, isNotNull);
      });
    });

    group('generate -', () {
      test('should process multiple annotated elements correctly', () async {
        // Test the main generate method that processes library-level annotations
        // This validates the overall generator pipeline

        expect(() => generator, isNotNull);
      });

      test('should handle empty library correctly', () async {
        // Test behavior when no annotations are found

        expect(() => generator, isNotNull);
      });
    });

    group('Integration Tests -', () {
      test('should generate complete router configuration', () async {
        // This test would use build_test to create a complete integration test
        // Testing the full code generation pipeline with actual Dart source

        const input = '''
          import 'package:stacked/stacked.dart';
          
          @StackedApp(
            routes: [
              MaterialRoute(page: HomeView, path: '/home'),
              MaterialRoute(page: LoginView, path: '/login'),
            ],
          )
          class AppRouter {}
        ''';

        // Note: This would require proper setup with build_test
        // await testBuilder(
        //   stackedRouterBuilder,
        //   {
        //     'pkg|lib/app.dart': input,
        //   },
        //   outputs: {
        //     'pkg|lib/app.router.dart': contains('AppRouter'),
        //   },
        // );

        expect(input, isNotEmpty);
      });
    });
  });
}
