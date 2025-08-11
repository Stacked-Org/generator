import 'package:stacked_generator/src/generators/bottomsheets/bottomsheet_config.dart';
import 'package:stacked_generator/src/generators/bottomsheets/generate/bottomsheet_class_generator.dart';
import 'package:test/test.dart';

import '../helpers/ast/bottomsheet_ast_validators.dart';

void main() {
  group('BottomsheetClassGeneratorTest -', () {
    group('generate -', () {
      test('When empty', () async {
        final generator = BottomsheetClassGenerator([]);
        final result = await generator.generate();
        
        BottomsheetClassGeneratorAstValidator.validateEmptyBottomsheetSetup(
          result,
          expectedLocatorCall: 'locator',
        );
      });
      test('When change locator name', () async {
        final generator =
            BottomsheetClassGenerator([], locatorName: 'customLocator');
        final result = await generator.generate();
        
        BottomsheetClassGeneratorAstValidator.validateEmptyBottomsheetSetup(
          result,
          expectedLocatorCall: 'customLocator',
        );
      });
      test('One bottomsheet', () async {
        final bottomsheets = [
          const BottomsheetConfig(
              import: 'one.dart', bottomsheetClassName: 'BasicBottomsheet')
        ];
        final generator = BottomsheetClassGenerator(bottomsheets);
        final result = await generator.generate();
        
        BottomsheetClassGeneratorAstValidator.validateBottomsheetSetup(
          result,
          expectedBottomsheets: bottomsheets,
          expectedLocatorCall: 'locator',
        );
      });
      test('Two bottomsheets', () async {
        final bottomsheets = [
          const BottomsheetConfig(
              import: 'one.dart', bottomsheetClassName: 'BasicBottomsheet'),
          const BottomsheetConfig(
              import: 'two.dart', bottomsheetClassName: 'ComplexBottomsheet')
        ];
        final generator = BottomsheetClassGenerator(bottomsheets);
        final result = await generator.generate();

        BottomsheetClassGeneratorAstValidator.validateBottomsheetSetup(
          result,
          expectedBottomsheets: bottomsheets,
          expectedLocatorCall: 'locator',
        );
      });
    });
  });
}
