import 'package:stacked_generator/src/generators/bottomsheets/bottomsheet_config.dart';
import 'package:stacked_generator/src/generators/bottomsheets/generate/bottomsheet_class_generator.dart';
import 'package:test/test.dart';

import '../helpers/test_constants/bottomsheets_constants.dart';

void main() {
  group('BottomsheetClassGeneratorTest -', () {
    group('generate -', () {
      test('When empty', () async {
        final generator = BottomsheetClassGenerator([]);
        expect(await generator.generate(), kBottomsheetsEmpty);
      });
      test('When change locator name', () async {
        final generator =
            BottomsheetClassGenerator([], locatorName: 'customLocator');
        expect(await generator.generate(), kBottomsheetsWithCustomNamedLocator);
      });
      test('One bottomsheet', () async {
        final generator = BottomsheetClassGenerator([
          const BottomsheetConfig(
              import: 'one.dart', bottomsheetClassName: 'BasicBottomsheet')
        ]);
        expect(await generator.generate(), kOneBottomsheet);
      });
      test('Two bottomsheets', () async {
        final generator = BottomsheetClassGenerator([
          const BottomsheetConfig(
              import: 'one.dart', bottomsheetClassName: 'BasicBottomsheet'),
          const BottomsheetConfig(
              import: 'two.dart', bottomsheetClassName: 'ComplexBottomsheet')
        ]);

        expect(await generator.generate(), kTwoBottomsheets);
      });
    });
  });
}
