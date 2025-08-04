import 'package:stacked_generator/src/generators/dialogs/dialog_config.dart';
import 'package:stacked_generator/src/generators/dialogs/generate/dialog_class_generator.dart';
import 'package:test/test.dart';

import '../helpers/test_constants/dialog_constant.dart';

void main() {
  group('DialogClassGeneratorTest -', () {
    group('generate -', () {
      test('When empty', () async {
        final generator = DialogClassGenerator([]);
        expect(await generator.generate(), kDialogsEmpty);
      });
      test('When change locator name', () async {
        final generator =
            DialogClassGenerator([], locatorName: 'customLocator');
        expect(await generator.generate(), kDialogsWithCustomNamedLocator);
      });
      test('One dialog', () async {
        final generator = DialogClassGenerator([
          const DialogConfig(import: 'one.dart', dialogClassName: 'BasicDialog')
        ]);
        expect(await generator.generate(), kOneDialog);
      });
      test('Two dialogs', () async {
        final generator = DialogClassGenerator([
          const DialogConfig(
              import: 'one.dart', dialogClassName: 'BasicDialog'),
          const DialogConfig(
              import: 'two.dart', dialogClassName: 'ComplexDialog')
        ]);

        expect(await generator.generate(), kTwoDialogs);
      });
    });
  });
}
