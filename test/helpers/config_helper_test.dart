import 'dart:convert';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:stacked_generator/src/generators/exceptions/config_file_not_found_exception.dart';
import 'package:stacked_generator/src/helpers/config_helper.dart';
import 'package:stacked_generator/src/models/stacked_config.dart';
import 'package:test/test.dart';

import 'mocks/test_helpers.mocks.dart';

const String ksTestFileName = 'mock_file.dart.test';

void createTestFile(String template) {
  File(ksTestFileName).writeAsStringSync(template);
}

Future<void> deleteTestFile() async {
  File file = File(ksTestFileName);
  if (await file.exists()) {
    await file.delete();
  }
}

void main() {
  setUp(() {
    createTestFile('');
  });

  tearDown(() async {
    await deleteTestFile();
  });

  group('ConfigHelper -', () {
    const String customConfigFilePath =
        '/Users/filledstacks/Desktop/stacked.json';

    final StackedConfig customConfig = StackedConfig.fromJson({
      "bottom_sheet_builder_file_path": "ui/setup/setup_bottom_sheet_ui.dart",
      "bottom_sheet_type_file_path": "enums/bottom_sheet_type.dart",
      "bottom_sheets_path": "ui/bottom_sheets",
      "dialog_builder_file_path": "ui/setup/setup_dialog_ui.dart",
      "dialog_type_file_path": "enums/dialog_type.dart",
      "dialogs_path": "ui/dialogs",
      "line_length": 80,
      "locator_name": "locator",
      "prefer_web": true,
      "register_mocks_function": "registerServices",
      "services_path": "my/personal/path/to/services",
      "stacked_app_file_path": "src/app/core.dart",
      "test_helpers_file_path": "lib/src/test/helpers/core_test.helpers.dart",
      "test_services_path": "my/personal/path/to/tests/service",
      "test_views_path": "my/personal/path/to/tests/viewmodel",
      "test_widgets_path": "my/personal/path/to/tests/widget_models",
      "v1": false,
      "views_path": "my/personal/path/to/views",
      "widgets_path": "ui/widgets/common"
    });

    group('composeConfigFile -', () {
      test('when called with configFilePath should return configFilePath',
          () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.fileExists(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => true);

        final path = await helper.composeConfigFile(
          configFilePath: customConfigFilePath,
        );

        expect(path, customConfigFilePath);
      });

      test(
          'when called with configFilePath should call fileExists on configFilePath',
          () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.fileExists(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => true);

        await helper.composeConfigFile(configFilePath: customConfigFilePath);

        verify(mockFileHelper.fileExists(filePath: customConfigFilePath));
      });

      test(
          'when called with configFilePath and file does NOT exists should throw ConfigFileNotFoundException with message equal kConfigFileNotFoundRetry and shouldHaltCommand equal true',
          () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.fileExists(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => false);

        expect(
          () => helper.composeConfigFile(configFilePath: customConfigFilePath),
          throwsA(predicate(
            (e) =>
                e is ConfigFileNotFoundException &&
                e.message == kConfigFileNotFoundRetry &&
                e.shouldHaltCommand == true,
          )),
        );
      });

      test('when called without configFilePath should return kConfigFileName',
          () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        final path = await helper.composeConfigFile();

        expect(path, kConfigFileName);
      });

      test(
          'when called without configFilePath and projectPath is NOT null should return kConfigFileName with projectPath',
          () async {
        const projectPath = 'example';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        final path = await helper.composeConfigFile(projectPath: projectPath);
        expect(path, '$projectPath/$kConfigFileName');
      });
    });

    group('loadConfig -', () {
      test('when called should call readFileAsString on FileService', () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => '{}');

        await helper.loadConfig(customConfigFilePath);
        verify(mockFileHelper.readFileAsString(filePath: customConfigFilePath));
      });

      test('when called should set hasCustomConfig as true', () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => '{}');

        await helper.loadConfig(customConfigFilePath);
        expect(helper.hasCustomConfig, isTrue);
      });

      test('when called should sanitize path', () async {
        const configToBeSanitize = {"services_path": "lib/services"};
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => configToBeSanitize.toString());

        await helper.loadConfig(customConfigFilePath);
        expect(helper.servicePath, 'services');
      });

      test(
          'when called and file not found should throw ConfigFileNotFoundException',
          () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenThrow(ConfigFileNotFoundException(
          kConfigFileNotFoundRetry,
          shouldHaltCommand: true,
        ));

        expect(
          () => helper.loadConfig(customConfigFilePath),
          throwsA(predicate(
            (e) =>
                e is ConfigFileNotFoundException &&
                e.message == kConfigFileNotFoundRetry &&
                e.shouldHaltCommand == true,
          )),
        );
      });

      test('when called and file is malformed should throw FormatException',
          () async {
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        expect(
          () => helper.loadConfig(customConfigFilePath),
          throwsA(predicate((e) => e is FormatException)),
        );
      }, skip: 'How can we trigger a FormatException from jsonDecode?');
    });

    group('replaceCustomPaths -', () {
      test('when called without custom config should return same path',
          () async {
        const path = 'test/services/generic_service_test.dart.stk';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => '{}');

        final customPath = helper.replaceCustomPaths(path);
        expect(customPath, path);
      });

      test('when called with custom config should return custom path',
          () async {
        const path = 'test/services/generic_service_test.dart.stk';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => jsonEncode(customConfig.toJson()));

        await helper.loadConfig(customConfigFilePath);
        final customPath = helper.replaceCustomPaths(path);
        expect(customPath, isNot(path));
        expect(
          customPath,
          'test/my/personal/path/to/services/generic_service_test.dart.stk',
        );
      });

      test(
          'when called with custom stacked app file path should return full stacked_app file path from config',
          () async {
        const path = 'app/app.dart';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => jsonEncode(customConfig.toJson()));

        await helper.loadConfig(customConfigFilePath);
        final customPath = helper.replaceCustomPaths(path);
        expect(customPath, isNot(path));
        expect(customPath, 'src/app/core.dart');
      });

      test(
          'when called with custom test_helpers file path should return full test_helpers file path from config',
          () async {
        const path = 'helpers/test_helpers.dart';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);

        when(
          mockFileHelper.readFileAsString(filePath: anyNamed('filePath')),
        ).thenAnswer((_) async => jsonEncode(customConfig.toJson()));

        await helper.loadConfig(customConfigFilePath);
        final customPath = helper.replaceCustomPaths(path);
        expect(customPath, isNot(path));
        expect(customPath, 'lib/src/test/helpers/core_test.helpers.dart');
      });
    });

    group('sanitizePath -', () {
      test(
          'when called with path equals "lib/src/services" should return "src/services"',
          () async {
        const path = 'lib/src/services';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.sanitizePath(path);
        expect(importPath, 'src/services');
      });

      test(
          'when called with path equals "src/lib/services" should return "src/lib/services"',
          () async {
        const path = 'src/lib/services';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.sanitizePath(path);
        expect(importPath, path);
      });

      test(
          'when called with path equals "src/services" should return "src/services"',
          () async {
        const path = 'src/services';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.sanitizePath(path);
        expect(importPath, path);
      });

      test(
          'when called with path equals "test/services" and find equals "test/" should return "services"',
          () async {
        const path = 'test/services';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.sanitizePath(path, 'test/');
        expect(importPath, 'services');
      });

      test(
          'when called with path equals "path/to/services" and find equals "test/" should return "path/to/services"',
          () async {
        const path = 'path/to/services';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.sanitizePath(path, 'test/');
        expect(importPath, path);
      });
    });

    group('getRelativePathToHelpersAndMocks -', () {
      test(
          'when called with path equals "service_tests" should return "../helpers/test_helpers.dart"',
          () async {
        const path = 'service_tests';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.getFilePathToHelpersAndMocks(path);
        expect(importPath, '../helpers/test_helpers.dart');
      });

      test(
          'when called with path equals "service_test" should return "../helpers/test_helpers.dart"',
          () async {
        const path = 'service_test';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.getFilePathToHelpersAndMocks(path);
        expect(importPath, '../helpers/test_helpers.dart');
      });

      test(
          'when called with path equals "path/to/service_test" should return "../../../helpers/test_helpers.dart"',
          () async {
        const path = 'path/to/service_test';
        final mockFileHelper = MockFileHelper();
        final helper = ConfigHelper(fileHelper: mockFileHelper);
        final importPath = helper.getFilePathToHelpersAndMocks(path);
        expect(importPath, '../../../helpers/test_helpers.dart');
      });
    });
  });
}
