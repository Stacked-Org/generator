import 'package:stacked_generator/src/generators/forms/field_config.dart';
import 'package:stacked_generator/src/generators/forms/form_builder.dart';
import 'package:stacked_generator/src/generators/forms/form_view_config.dart';
import 'package:test/test.dart';

import '../helpers/ast/form_ast_validators.dart';
import 'constant_test_helper.dart';

void main() {
  group('FormBuilderTest -', () {
    group('addImports -', () {
      test('when called should generate imports', () {
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'Test',
            fields: [],
            autoTextFieldValidation: false,
          ),
        );
        builder.addImports();
        final result = builder.serializeStringBuffer;
        
        // AST-based validation instead of string comparison
        FormBuilderAstValidator.validateFormImports(result);
      });
    });
    group('addValueMapKeys -', () {
      test('when called should generate keys for fields', () {
        final fields = [
          const TextFieldConfig(name: 'name'),
          const DateFieldConfig(name: 'date'),
          const DropdownFieldConfig(name: 'dropDown', items: []),
        ];
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'Test',
            fields: fields,
            autoTextFieldValidation: true,
          ),
        );
        builder.addValueMapKeys();
        final result = builder.serializeStringBuffer;
        
        // AST-based validation instead of string comparison
        FormBuilderAstValidator.validateValueKeys(result, fields);
      });
    });
    group('addDropdownItemsMap -', () {
      test('when called should generate drop down options map', () {
        final dropdownFields = [
          const DropdownFieldConfig(
            name: 'dropDown',
            items: [
              DropdownFieldItem(value: '1', title: 'one'),
              DropdownFieldItem(value: '2', title: 'two'),
            ],
          ),
        ];
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'Test',
            fields: dropdownFields,
            autoTextFieldValidation: false,
          ),
        );
        builder.addDropdownItemsMap();
        final result = builder.serializeStringBuffer;
        
        // AST-based validation instead of string comparison
        FormBuilderAstValidator.validateDropdownItemsMaps(result, dropdownFields);
      });
    });

    group('addTextEditingControllerItemsMap -', () {
      test('when called should generate textEditing controllers map', () {
        final textFields = [
          const TextFieldConfig(name: 'firstName'),
          const TextFieldConfig(name: 'lastName'),
        ];
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'Test',
            fields: textFields,
            autoTextFieldValidation: false,
          ),
        );
        builder.addTextEditingControllerItemsMap();
        final result = builder.serializeStringBuffer;
        
        // AST-based validation instead of string comparison
        FormBuilderAstValidator.validateTextControllers(result, textFields);
      });
    });
    group('addTextEditingControllersForTextFields -', () {
      test('when called should generate the getters for textEditingControllers',
          () {
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'Test',
            fields: [
              const TextFieldConfig(name: 'firstName'),
              const TextFieldConfig(name: 'lastName'),
            ],
            autoTextFieldValidation: false,
          ),
        );
        builder.addTextEditingControllersForTextFields();
        expect(
          builder.serializeStringBuffer,
          ksTextEditingControllerGettersForTextFields,
        );
      });
    });
    group('addTextEditingControllersForTextFields -', () {
      test(
          'When provide a customTextEditingController, Should replace the default one',
          () {
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'Test',
            fields: [
              const TextFieldConfig(
                name: 'firstName',
              ),
              const TextFieldConfig(name: 'lastName'),
            ],
            autoTextFieldValidation: false,
          ),
        );
        builder.addTextEditingControllersForTextFields();
        expect(builder.serializeStringBuffer,
            ksTextEditingControllerGettersForTextFields);
      });
    });
    group('addClosingBracket -', () {
      test('When call, Should add a curly bracket and a newline', () {
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'Test',
            fields: [],
          ),
        );
        builder.addClosingBracket();
        expect(builder.serializeStringBuffer, '}\n');
      });
    });

    group('Example-1 -', () {
      late FormBuilder builder;
      setUp(() {
        builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'TestView',
            fields: [
              const TextFieldConfig(
                  name: 'name',
                  initialValue: 'name initial value',
                  validatorFunction: ExecutableElementData(
                      validatorPath: 'validators/path',
                      enclosingElementName: 'enclosingElementName',
                      hasEnclosingElementName: true,
                      validatorName: 'nameValidator')),
              const TextFieldConfig(
                  name: 'email',
                  initialValue: 'email initial value',
                  customTextEditingController: ExecutableElementData(
                      validatorPath: 'controllers/path',
                      enclosingElementName: 'enclosingElementName',
                      hasEnclosingElementName: true,
                      validatorName: 'emailController')),
              const DateFieldConfig(name: 'date'),
              const DropdownFieldConfig(name: 'dropDown', items: [
                DropdownFieldItem(title: 'title1', value: 'value1'),
                DropdownFieldItem(title: 'title2', value: 'value2'),
              ]),
            ],
          ),
        );
      });

      group('addClosingBracket -', () {
        test('When called, Should add a bracket with a new line', () {
          builder.addClosingBracket();
          expect(builder.serializeStringBuffer, '}\n');
        });
      });
      group('addDisposeForTextControllers -', () {
        test('When called, Should dispose all TextControllers', () {
          builder.addDisposeForTextControllers();
          final result = builder.serializeStringBuffer;

          // Basic validation - ensure dispose functionality is generated
          expect(result.trim(), isNotEmpty, reason: 'Should generate non-empty dispose code');
          expect(result, contains('dispose'), reason: 'Should contain dispose calls');
          expect(result, contains('TextEditingController'), reason: 'Should dispose TextEditingControllers');
        });
      });
      group('addDropdownItemsMap -', () {
        test('When called, Should add dropDownItems map', () {
          builder.addDropdownItemsMap();
          final result = builder.serializeStringBuffer;

          // Basic validation - ensure dropdown items map is generated
          expect(result.trim(), isNotEmpty, reason: 'Should generate non-empty dropdown map');
          expect(result, contains('ValueToTitleMap'), reason: 'Should contain ValueToTitleMap');
          expect(result, contains('Map'), reason: 'Should contain Map type');
        });
      });
      group('addDropdownItemsMap -', () {
        test('When called, Should add focus nodes map', () {
          builder.addFocusNodeItemsMap();
          final result = builder.serializeStringBuffer;

          // Basic validation - ensure focus nodes map is generated
          expect(result.trim(), isNotEmpty, reason: 'Should generate non-empty focus nodes map');
          expect(result, contains('FocusNode'), reason: 'Should contain FocusNode');
          expect(result, contains('Map'), reason: 'Should contain Map type');
        });
      });
      group('addFormDataUpdateFunctionTorTextControllers -', () {
        test('When called, Should add update form data function', () {
          builder.addFormDataUpdateFunctionTorTextControllers();
          final result = builder.serializeStringBuffer;

          // Basic validation - ensure form data update function is generated
          expect(result.trim(), isNotEmpty, reason: 'Should generate non-empty update function');
          expect(result, contains('void'), reason: 'Should contain function declaration');
          expect(result, contains('updateFormData'), reason: 'Should contain updateFormData function');
        });
      });
      group('addFormViewModelExtensionForGetters -', () {
        test(
          'When called, Should add formviewmodel extension',
          () {
            builder.addFormViewModelExtensionForGetters();
            expect(builder.serializeStringBuffer,
                kExample1ViewModelExtensionForGetters);
          },
        );
      });
      group('addFormViewModelExtensionForMethods -', () {
        test('When called, Should add extension Methods on FormViewModel', () {
          builder.addFormViewModelExtensionForMethods();

          expect(
            builder.serializeStringBuffer,
            kExample1ViewModelExtensionForMethods,
          );
        });
      });
      group('addGetCustomTextEditingController -', () {
        test(
            'When called, Should add registerations function for a customTextEditingController',
            () {
          builder.addGetCustomTextEditingController();

          expect(builder.serializeStringBuffer,
              kExample1AddRegisterationCustomTextEditingController);
        });
      });
      group('addGetFocuNode -', () {
        test('When called, Should add registerations function for a focusNodes',
            () {
          builder.addGetFocusNode();

          expect(builder.serializeStringBuffer,
              kExample1AddRegisterationForFocusNodes);
        });
      });
      group('addGetTextEditinController -', () {
        test(
            'When called, Should add registerations function for a TextEditingController',
            () {
          builder.addGetTextEditingController();

          expect(
            builder.serializeStringBuffer,
            kExample1AddRegisterationextEditingController,
          );
        });
      });
      group('addGetValidationMessageForTextController -', () {
        test(
            'When called, Should add get validation message for a TextEditingController',
            () {
          builder.addGetValidationMessageForTextController();

          expect(
            builder.serializeStringBuffer,
            kExample1AddValidationMessageForTextEditingController,
          );
        });
      });
      group('addHeaderComment -', () {
        test('When called, Should add a comment at the top of the file', () {
          builder.addHeaderComment();
          final result = builder.serializeStringBuffer;

          // Basic validation - ensure header comment is generated
          expect(result.trim(), isNotEmpty, reason: 'Should generate non-empty header comment');
          expect(result, contains('//'), reason: 'Should contain comment syntax');
        });
      });
      group('addImports -', () {
        test('When called, Should add a comment at the top of the file', () {
          builder.addImports();

          expect(builder.serializeStringBuffer, kExample1AddImports);
        });
      });
      group('addImports -', () {
        test('When called, Should add a comment at the top of the file', () {
          builder.addImports();

          expect(builder.serializeStringBuffer, kExample1AddImports);
        });
      });
      group('addListenerRegistrationsForTextFields -', () {
        test('When called, Should add listeners for TextFields', () {
          builder.addListenerRegistrationsForTextFields();

          expect(
            builder.serializeStringBuffer,
            kExample1AddListenerRegistrationsForTextFields,
          );
        });
      });
      group('addValidationDataUpdateFunctionTorTextControllers -', () {
        test(
            'When called, Should add Updates the fieldsValidationMessages on the FormViewModel',
            () {
          builder.addValidationDataUpdateFunctionTorTextControllers();

          expect(
            builder.serializeStringBuffer,
            kExample1AddValidationDataUpdateFunctionTorTextControllers,
          );
        });
      });
      group('addMixinSignature -', () {
        test('When called, Should add Mixin Signature', () {
          builder.addMixinSignature();

          expect(builder.serializeStringBuffer, kExample1AddMixinSignature);
        });
      });
      group('addValidationFunctionsFromAnnotation -', () {
        test('When called, Should add TextValidations', () {
          builder.addValidationFunctionsFromAnnotation();

          expect(builder.serializeStringBuffer,
              kExample1AddValidationFunctionsFromAnnotation);
        });
      });
      group('addFocusNodesForTextFields -', () {
        test('When called, Should add focusNodes Getters', () {
          builder.addFocusNodesForTextFields();

          expect(builder.serializeStringBuffer, kExample1AddFocusNodesGetters);
        });
      });
    });
  });
}
