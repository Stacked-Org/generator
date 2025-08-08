import 'package:stacked_generator/src/generators/dialogs/dialog_config.dart';
import 'package:stacked_generator/src/generators/dialogs/generate/dialog_class_generator.dart';
import 'package:test/test.dart';

import '../helpers/ast/dialog_ast_validators.dart';

void main() {
  group('DialogClassGeneratorTest -', () {
    group('generate -', () {
      test('When empty', () async {
        final generator = DialogClassGenerator([]);
        final result = await generator.generate();
        
        DialogClassGeneratorAstValidator.validateEmptyDialogSetup(result);
      });
      test('When change locator name', () async {
        final generator =
            DialogClassGenerator([], locatorName: 'customLocator');
        final result = await generator.generate();
        
        DialogClassGeneratorAstValidator.validateEmptyDialogSetup(
          result,
          expectedLocatorCall: 'customLocator',
        );
      });
      test('One dialog', () async {
        final dialogs = [
          const DialogConfig(import: 'one.dart', dialogClassName: 'BasicDialog')
        ];
        final generator = DialogClassGenerator(dialogs);
        final result = await generator.generate();
        
        DialogClassGeneratorAstValidator.validateDialogSetup(
          result,
          expectedDialogs: dialogs,
        );
      });
      test('Two dialogs', () async {
        final dialogs = [
          const DialogConfig(
              import: 'one.dart', dialogClassName: 'BasicDialog'),
          const DialogConfig(
              import: 'two.dart', dialogClassName: 'ComplexDialog')
        ];
        final generator = DialogClassGenerator(dialogs);
        final result = await generator.generate();

        DialogClassGeneratorAstValidator.validateDialogSetup(
          result,
          expectedDialogs: dialogs,
        );
      });
    });
  });
}
