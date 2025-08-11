import 'dart:convert';

import 'package:stacked_generator/src/helpers/config_helper.dart';
import 'package:stacked_generator/src/helpers/file_helper.dart';
import 'package:test/test.dart';

class TestableFileHelper extends FileHelper {
  final Map<String, String> _files = {};
  final Map<String, bool> _fileExists = {};

  void setFileContent(String filePath, String content) {
    _files[filePath] = content;
    _fileExists[filePath] = true;
  }

  void setFileExists(String filePath, bool exists) {
    _fileExists[filePath] = exists;
  }

  @override
  Future<bool> fileExists({required String filePath}) async {
    return _fileExists[filePath] ?? false;
  }

  @override
  Future<String> readFileAsString({required String filePath}) async {
    if (_files.containsKey(filePath)) {
      return _files[filePath]!;
    }
    throw Exception('File not found: $filePath');
  }
}

void main() {
  group('ConfigHelper Utility Tests -', () {
    late ConfigHelper configHelper;
    late TestableFileHelper testFileHelper;

    setUp(() {
      testFileHelper = TestableFileHelper();
      configHelper = ConfigHelper(fileHelper: testFileHelper);
    });

    group('Path Sanitization -', () {
      test('should remove lib/ prefix from paths', () {
        final result = configHelper.sanitizePath('lib/services/auth_service.dart');
        expect(result, equals('services/auth_service.dart'));
      });

      test('should remove test/ prefix when specified', () {
        final result = configHelper.sanitizePath('test/services/auth_service_test.dart', 'test/');
        expect(result, equals('services/auth_service_test.dart'));
      });

      test('should not modify paths without the specified prefix', () {
        final result = configHelper.sanitizePath('services/auth_service.dart');
        expect(result, equals('services/auth_service.dart'));
      });

      test('should handle empty paths', () {
        final result = configHelper.sanitizePath('');
        expect(result, equals(''));
      });

      test('should handle paths with only the prefix', () {
        final result = configHelper.sanitizePath('lib/');
        expect(result, equals(''));
      });

      test('should only remove the first occurrence of prefix', () {
        final result = configHelper.sanitizePath('lib/lib/services/auth.dart');
        expect(result, equals('lib/services/auth.dart'));
      });
    });

    group('Test Helpers Path Calculation -', () {
      test('should calculate correct relative path for single level', () {
        final result = configHelper.getFilePathToHelpersAndMocks('services');
        expect(result, equals('../helpers/test_helpers.dart'));
      });

      test('should calculate correct relative path for multiple levels', () {
        final result = configHelper.getFilePathToHelpersAndMocks('views/auth/login');
        expect(result, equals('../../../helpers/test_helpers.dart'));
      });

      test('should handle paths with file extensions', () {
        final result = configHelper.getFilePathToHelpersAndMocks('services/auth_service.dart');
        // File extensions should be ignored in path calculation
        expect(result, equals('../helpers/test_helpers.dart'));
      });

      test('should handle empty paths', () {
        final result = configHelper.getFilePathToHelpersAndMocks('');
        expect(result, equals('../helpers/test_helpers.dart'));
      });

      test('should handle very deep nested paths', () {
        final result = configHelper.getFilePathToHelpersAndMocks('a/b/c/d/e/f');
        expect(result, equals('../../../../../../helpers/test_helpers.dart'));
      });
    });

    group('Config File Path Composition -', () {
      test('should return provided path when file exists', () async {
        const configPath = '/custom/config.json';
        testFileHelper.setFileExists(configPath, true);

        final result = await configHelper.composeConfigFile(
          configFilePath: configPath,
        );

        expect(result, equals(configPath));
      });

      test('should return default filename when no parameters provided', () async {
        final result = await configHelper.composeConfigFile();
        expect(result, equals('stacked.json'));
      });

      test('should combine project path with default filename', () async {
        const projectPath = '/project/root';
        final result = await configHelper.composeConfigFile(
          projectPath: projectPath,
        );
        expect(result, equals('$projectPath/stacked.json'));
      });

      test('should handle empty project path', () async {
        final result = await configHelper.composeConfigFile(projectPath: '');
        expect(result, equals('/stacked.json'));
      });
    });

    group('Default Configuration Values -', () {
      test('should have correct default values when no custom config loaded', () {
        expect(configHelper.hasCustomConfig, isFalse);
        expect(configHelper.servicePath, equals('services'));
        expect(configHelper.viewPath, equals('ui/views'));
        expect(configHelper.locatorName, equals('locator'));
        expect(configHelper.v1, isFalse);
        expect(configHelper.lineLength, equals(80));
      });

      test('should return correct default import paths', () {
        expect(configHelper.serviceImportPath, equals('services'));
        expect(configHelper.viewImportPath, equals('ui/views'));
        expect(configHelper.widgetPath, equals('ui/widgets/common'));
        expect(configHelper.dialogsPath, equals('ui/dialogs'));
        expect(configHelper.bottomSheetsPath, equals('ui/bottom_sheets'));
      });

      test('should return correct default file paths', () {
        expect(configHelper.stackedAppFilePath, equals('app/app.dart'));
        expect(configHelper.testHelpersFilePath, equals('helpers/test_helpers.dart'));
        expect(configHelper.dialogBuilderFilePath, equals('ui/setup/setup_dialog_ui.dart'));
        expect(configHelper.bottomSheetBuilderFilePath, equals('ui/setup/setup_bottom_sheet_ui.dart'));
      });
    });

    group('Configuration Loading -', () {
      test('should load valid JSON configuration', () async {
        final customConfig = {
          'services_path': 'api/services',
          'views_path': 'ui/views',
          'locator_name': 'appLocator',
          'v1': true,
          'line_length': 120,
        };

        testFileHelper.setFileContent('config.json', json.encode(customConfig));
        await configHelper.loadConfig('config.json');

        expect(configHelper.hasCustomConfig, isTrue);
        expect(configHelper.servicePath, equals('api/services'));
        expect(configHelper.viewPath, equals('ui/views'));
        expect(configHelper.locatorName, equals('appLocator'));
        expect(configHelper.v1, isTrue);
        expect(configHelper.lineLength, equals(120));
      });

      test('should handle malformed JSON gracefully', () async {
        testFileHelper.setFileContent('malformed.json', '{ invalid json }');
        
        // Should not throw but handle gracefully
        await configHelper.loadConfig('malformed.json');
        expect(configHelper.hasCustomConfig, isFalse);
      });

      test('should handle empty JSON configuration', () async {
        testFileHelper.setFileContent('empty.json', '{}');
        await configHelper.loadConfig('empty.json');

        expect(configHelper.hasCustomConfig, isTrue);
        // Should still use defaults for unspecified values
        expect(configHelper.servicePath, equals('services'));
      });

      test('should handle partial configuration', () async {
        final partialConfig = {'locator_name': 'customLocator'};
        testFileHelper.setFileContent('partial.json', json.encode(partialConfig));
        
        await configHelper.loadConfig('partial.json');

        expect(configHelper.hasCustomConfig, isTrue);
        expect(configHelper.locatorName, equals('customLocator'));
        // Other values should remain defaults
        expect(configHelper.servicePath, equals('services'));
        expect(configHelper.v1, isFalse);
      });
    });

    group('Widget Path Override -', () {
      test('should update widgets path when provided', () {
        configHelper.setWidgetsPath('custom_widgets');
        expect(configHelper.widgetPath, equals('custom_widgets'));
      });

      test('should keep existing path when null provided', () {
        final originalPath = configHelper.widgetPath;
        configHelper.setWidgetsPath(null);
        expect(configHelper.widgetPath, equals(originalPath));
      });

      test('should handle empty string override', () {
        configHelper.setWidgetsPath('');
        expect(configHelper.widgetPath, equals(''));
      });
    });

    group('Path Replacement -', () {
      test('should not replace paths when no custom config exists', () {
        const path = 'lib/services/auth_service.dart';
        final result = configHelper.replaceCustomPaths(path);
        expect(result, equals(path));
      });

      test('should replace default paths with custom paths', () async {
        final customConfig = {'services_path': 'custom_services'};
        testFileHelper.setFileContent('custom.json', json.encode(customConfig));
        
        await configHelper.loadConfig('custom.json');

        const originalPath = 'lib/services/auth_service.dart';
        final result = configHelper.replaceCustomPaths(originalPath);
        
        expect(result, contains('custom_services'));
        expect(result, isNot(contains('/services/')));
      });

      test('should handle paths that do not match any defaults', () async {
        final customConfig = {'services_path': 'custom_services'};
        testFileHelper.setFileContent('custom.json', json.encode(customConfig));
        
        await configHelper.loadConfig('custom.json');

        const nonMatchingPath = 'lib/models/user_model.dart';
        final result = configHelper.replaceCustomPaths(nonMatchingPath);
        
        expect(result, equals(nonMatchingPath)); // Should remain unchanged
      });
    });

    group('Configuration Export -', () {
      test('should export configuration as JSON string', () async {
        final customConfig = {
          'services_path': 'api_services',
          'locator_name': 'myLocator',
        };
        testFileHelper.setFileContent('export_test.json', json.encode(customConfig));
        
        await configHelper.loadConfig('export_test.json');
        final exported = configHelper.exportConfig();

        expect(exported, isA<String>());
        expect(exported, contains('api_services'));
        expect(exported, contains('myLocator'));
        
        // Should be formatted with indentation
        expect(exported, contains('    '));
        
        // Should be valid JSON
        expect(() => json.decode(exported), returnsNormally);
      });

      test('should export default configuration when no custom config loaded', () {
        final exported = configHelper.exportConfig();

        expect(exported, isA<String>());
        expect(exported, contains('services'));
        expect(exported, contains('locator'));
        
        // Should be valid JSON
        expect(() => json.decode(exported), returnsNormally);
      });
    });
  });
}