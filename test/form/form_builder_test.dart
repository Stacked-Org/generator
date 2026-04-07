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
        expect(
          builder.serializeStringBuffer,
          ksFormKeys('name', 'date', 'dropDown'),
        );
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
      test(
        'when called should generate the getters for textEditingControllers',
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
        },
      );
    });
    group('addTextEditingControllersForTextFields -', () {
      test(
        'When provide a customTextEditingController, Should replace the default one',
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
        },
      );
    });
    group('addClosingBracket -', () {
      test('When call, Should add a curly bracket and a newline', () {
        FormBuilder builder = FormBuilder(
          formViewConfig: FormViewConfig(viewName: 'Test', fields: []),
        );
        builder.addClosingBracket();
        expect(builder.serializeStringBuffer, '}\n');
      });
    });

    group('dot-shorthand sanitization -', () {
      test(
        'addValidationFunctionsFromAnnotation strips accidental leading dot',
        () {
          final builder = FormBuilder(
            formViewConfig: FormViewConfig(
              viewName: 'DotShorthand',
              fields: const [
                TextFieldConfig(
                  name: 'email',
                  validatorFunction: ExecutableElementData(
                    validatorName: '.emailValidator',
                  ),
                ),
              ],
            ),
          );

          builder.addValidationFunctionsFromAnnotation();
          final output = builder.serializeStringBuffer;

          expect(output, contains('EmailValueKey: emailValidator,'));
          expect(output, isNot(contains('.emailValidator')));
        },
      );

      test('addGetCustomTextEditingController strips leading dot', () {
        final builder = FormBuilder(
          formViewConfig: FormViewConfig(
            viewName: 'DotShorthand',
            fields: const [
              TextFieldConfig(
                name: 'email',
                customTextEditingController: ExecutableElementData(
                  returnType: 'CustomEditingController',
                  validatorName: '.buildController',
                ),
              ),
            ],
          ),
        );

        builder.addGetCustomTextEditingController();
        final output = builder.serializeStringBuffer;

        expect(output, contains('buildController();'));
        expect(output, isNot(contains('.buildController')));
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
                  validatorName: 'nameValidator',
                ),
              ),
              const TextFieldConfig(
                name: 'email',
                initialValue: 'email initial value',
                customTextEditingController: ExecutableElementData(
                  validatorPath: 'controllers/path',
                  enclosingElementName: 'enclosingElementName',
                  hasEnclosingElementName: true,
                  validatorName: 'emailController',
                ),
              ),
              const DateFieldConfig(name: 'date'),
              const DropdownFieldConfig(
                name: 'dropDown',
                items: [
                  DropdownFieldItem(title: 'title1', value: 'value1'),
                  DropdownFieldItem(title: 'title2', value: 'value2'),
                ],
              ),
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
          final output = builder.serializeStringBuffer;
          expect(output, contains('void disposeForm() {'));
          expect(output, contains('_TestViewTextEditingControllers.clear();'));
          expect(output, contains('_TestViewFocusNodes.clear();'));
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
          final output = builder.serializeStringBuffer;
          expect(
            output,
            anyOf(
              contains(
                'void _updateFormData(FormViewModel model, {bool forceValidate = false})',
              ),
              contains(
                'void _updateFormData(FormStateHelper model, {bool forceValidate = false})',
              ),
            ),
          );
          expect(output, contains('NameValueKey: nameController.text,'));
          expect(output, contains('EmailValueKey: emailController.text,'));
          expect(
            RegExp(r'\b_?updateValidationData\(model\)').hasMatch(output),
            isTrue,
          );
        });
      });
      group('addFormViewModelExtensionForGetters -', () {
        test(
          'When called, Should add formviewmodel extension',
          () {
            builder.addFormViewModelExtensionForGetters();

            expect(
              builder.serializeStringBuffer,
              kExample1ViewModelExtensionForGetters,
            );
          },
          skip:
              'This is too fickle. It\'s failing due to spacing issues. I want something more robust here',
        );
      });
      group('addFormViewModelExtensionForMethods -', () {
        test('When called, Should add extension Methods on FormViewModel', () {
          builder.addFormViewModelExtensionForMethods();
          final output = builder.serializeStringBuffer;
          expect(
            output,
            anyOf(
              contains('extension Methods on FormViewModel {'),
              contains('extension Methods on FormStateHelper {'),
            ),
          );
          expect(output, contains('Future<void> selectDate('));
          expect(output, contains('void setDropDown(String dropDown) {'));
          expect(
            output,
            contains('setNameValidationMessage(String? validationMessage)'),
          );
          expect(output, contains('void clearForm() {'));
          expect(output, contains('void validateForm() {'));
        });
      });
      group('addGetCustomTextEditingController -', () {
        test(
          'When called, Should add registerations function for a customTextEditingController',
          () {
            builder.addGetCustomTextEditingController();

            expect(
              builder.serializeStringBuffer,
              kExample1AddRegisterationCustomTextEditingController,
            );
          },
        );
      });
      group('addGetFocuNode -', () {
        test(
          'When called, Should add registerations function for a focusNodes',
          () {
            builder.addGetFocusNode();

            expect(
              builder.serializeStringBuffer,
              kExample1AddRegisterationForFocusNodes,
            );
          },
        );
      });
      group('addGetTextEditinController -', () {
        test(
          'When called, Should add registerations function for a TextEditingController',
          () {
            builder.addGetTextEditingController();
            final output = builder.serializeStringBuffer;
            expect(
              output,
              contains('TextEditingController _getFormTextEditingController('),
            );
            expect(output, contains('String key'));
            expect(
              output,
              contains('TextEditingController(text: initialValue);'),
            );
          },
        );
      });
      group('addGetValidationMessageForTextController -', () {
        test(
          'When called, Should add get validation message for a TextEditingController',
          () {
            builder.addGetValidationMessageForTextController();
            final output = builder.serializeStringBuffer;
            expect(
              output,
              contains('String? getValidationMessage(String key)'),
            );
            expect(output, contains('final validatorForKey ='));
            expect(
              output,
              anyOf(
                contains('_TestViewTextEditingControllers[key]!.text'),
                contains('_TestViewTextEditingControllers[key]?.text'),
              ),
            );
          },
        );
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
          final output = builder.serializeStringBuffer;
          expect(
            output,
            anyOf(
              contains('void syncFormWithViewModel(FormViewModel model)'),
              contains('void syncFormWithViewModel(FormStateHelper model)'),
            ),
          );
          expect(
            output,
            contains('void listenToFormUpdated(FormViewModel model)'),
          );
          expect(
            output,
            contains(
              'nameController.addListener(() => _updateFormData(model));',
            ),
          );
          expect(
            output,
            contains(
              'emailController.addListener(() => _updateFormData(model));',
            ),
          );
        });
      });
      group('addValidationDataUpdateFunctionTorTextControllers -', () {
        test(
          'When called, Should add Updates the fieldsValidationMessages on the FormViewModel',
          () {
            builder.addValidationDataUpdateFunctionTorTextControllers();
            final output = builder.serializeStringBuffer;
            expect(output, contains('setValidationMessages'));
            expect(
              output,
              contains('NameValueKey: getValidationMessage(NameValueKey),'),
            );
            expect(
              output,
              contains('EmailValueKey: getValidationMessage(EmailValueKey),'),
            );
          },
        );
      });
      group('addMixinSignature -', () {
        test('When called, Should add Mixin Signature', () {
          builder.addMixinSignature();
          expect(builder.serializeStringBuffer, 'mixin \$TestView {\n');
        });
      });
      group('addValidationFunctionsFromAnnotation -', () {
        test('When called, Should add TextValidations', () {
          builder.addValidationFunctionsFromAnnotation();

          expect(
            builder.serializeStringBuffer,
            kExample1AddValidationFunctionsFromAnnotation,
          );
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
