import 'dart:convert';
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stacked_generator/src/generators/exceptions/config_file_not_found_exception.dart';
import 'package:stacked_generator/src/helpers/file_helper.dart';
import 'package:stacked_generator/src/models/stacked_config.dart';

const kConfigFileMalformed =
    'Your configuration file is malformed. Double check to make sure you have properly formatted json.';
const kConfigFileName = 'stacked.json';
const kConfigFileNotFound =
    'No configuration file found. Default Stacked values will be used.';
const kConfigFileNotFoundRetry =
    'No configuration file found. Please, verify the config path passed as argument.';
const kDeprecatedPaths =
    'Paths on Stacked config do not need to start with directory "lib" or "test" because  are mandatory directories, defined by the Flutter framework. Stacked cli will not accept paths starting with "lib" or "test" after the next minor release.';

/// Handles stacked app configuration
class ConfigHelper {
  final FileHelper fileHelper;
  ConfigHelper({required this.fileHelper});

  /// Default config map used to compare and replace with custom values.
  final Map<String, dynamic> _defaultConfig = StackedConfig().toJson();

  /// Custom config used to store custom values read from file.
  StackedConfig _customConfig = StackedConfig();

  bool _hasCustomConfig = false;

  bool get hasCustomConfig => _hasCustomConfig;

  /// Relative services path for import statements.
  String get serviceImportPath => _customConfig.servicesPath;

  /// Relative path where services will be genereated.
  String get servicePath => _customConfig.servicesPath;

  /// Returns the name of the locator to use when registering service mocks.
  String get locatorName => _customConfig.locatorName;

  String get registerMocksFunction => _customConfig.registerMocksFunction;

  /// Relative import path related to services of test helpers and mock services.
  String get serviceTestHelpersImport => getFilePathToHelpersAndMocks(
        _customConfig.testServicesPath,
      );

  /// Relative bottom sheet path for import statements.
  String get bottomSheetsPath => _customConfig.bottomSheetsPath;

  /// File path where bottom sheet builders are located.
  String get bottomSheetBuilderFilePath =>
      _customConfig.bottomSheetBuilderFilePath;

  /// File path where bottom sheet type enum values are located.
  String get bottomSheetTypeFilePath => _customConfig.bottomSheetTypeFilePath;

  /// Relative path where dialogs will be genereated.
  String get dialogsPath => _customConfig.dialogsPath;

  /// File path where dialog builders are located.
  String get dialogBuilderFilePath => _customConfig.dialogBuilderFilePath;

  /// File path where dialog type enum values are located.
  String get dialogTypeFilePath => _customConfig.dialogTypeFilePath;

  /// File path where StackedApp is setup.
  String get stackedAppFilePath => _customConfig.stackedAppFilePath;

  /// File path where register functions for unit test setup and mock
  /// declarations are located.
  String get testHelpersFilePath => _customConfig.testHelpersFilePath;

  /// Relative path where services unit tests will be genereated.
  String get testServicesPath => _customConfig.testServicesPath;

  /// Relative path where viewmodels unit tests will be genereated.
  String get testViewsPath => _customConfig.testViewsPath;

  /// Relative views path for import statements.
  String get viewImportPath => _customConfig.viewsPath;

  /// Relative path where views and viewmodels will be genereated.
  String get viewPath => _customConfig.viewsPath;

  /// Relative import path related to viewmodels of test helpers and mock services.
  String get viewTestHelpersImport => getFilePathToHelpersAndMocks(
        _customConfig.testViewsPath,
      );

  /// Relative path where widgets will be genereated.
  String get widgetPath => _customConfig.widgetsPath;

  /// Relative import path related to widget models of test helpers and mock services.
  String get widgetTestHelpersImport => getFilePathToHelpersAndMocks(
        _customConfig.testWidgetsPath,
      );

  /// Returns boolean value to determine view builder style.
  ///
  /// False: StackedView
  /// True: ViewModelBuilder
  bool get v1 => _customConfig.v1;

  /// Returns int value for line length when format code.
  int get lineLength => _customConfig.lineLength;

  /// Returns boolean to indicate if the project prefers web templates
  bool get preferWeb => _customConfig.preferWeb;

  /// Composes configuration file and loads it into memory.
  ///
  /// Generally used to load the configuration file at root of the project.
  Future<void> composeAndLoadConfigFile({
    String? configFilePath,
    String? projectPath,
  }) async {
    try {
      final configPath = await composeConfigFile(
        configFilePath: configFilePath,
        projectPath: projectPath,
      );

      await loadConfig(configPath);
    } on ConfigFileNotFoundException catch (e) {
      if (e.shouldHaltCommand) rethrow;

      stdout.writeln(e.message);
    } catch (e) {
      stdout.writeln(e.toString());
    }
  }

  /// Returns configuration file path.
  ///
  /// When configFilePath is NOT null should returns configFilePath unless the
  /// file does NOT exists where should throw a ConfigFileNotFoundException.
  ///
  /// When configFilePath is null should returns [kConfigFileName] or with the
  /// []projectPath] included if it was passed through arguments.
  @visibleForTesting
  Future<String> composeConfigFile({
    String? configFilePath,
    String? projectPath,
  }) async {
    if (configFilePath != null) {
      if (await fileHelper.fileExists(filePath: configFilePath)) {
        return configFilePath;
      }

      throw ConfigFileNotFoundException(
        kConfigFileNotFoundRetry,
        shouldHaltCommand: true,
      );
    }

    if (projectPath != null) {
      return '$projectPath/$kConfigFileName';
    }

    return kConfigFileName;
  }

  /// Reads configuration file and sets data to [_customConfig] map.
  @visibleForTesting
  Future<void> loadConfig(String configFilePath) async {
    try {
      final data = await fileHelper.readFileAsString(
        filePath: configFilePath,
      );
      _customConfig = StackedConfig.fromJson(jsonDecode(data));
      _hasCustomConfig = true;
      _sanitizeCustomConfig();
    } on ConfigFileNotFoundException catch (e) {
      if (e.shouldHaltCommand) rethrow;

      stdout.writeln(e.message);
    } on FormatException catch (_) {
      stdout.writeln(kConfigFileMalformed);
    } catch (e) {
      stdout.writeln(e.toString());
    }
  }

  /// Replaces the default configuration in [path] by custom configuration
  /// available at [customConfig].
  ///
  /// If [hasCustomConfig] is false, returns [path] without modifications.
  String replaceCustomPaths(String path) {
    if (!hasCustomConfig) return path;

    final customConfig = _customConfig.toJson();
    String customPath = path;

    for (var k in _defaultConfig.keys) {
      // Avoid trying to replace non path values like v1 or lineLength
      if (!k.contains('path')) continue;

      if (customPath.contains(_defaultConfig[k])) {
        customPath = customPath.replaceFirst(
          _defaultConfig[k],
          customConfig[k],
        );
        break;
      }
    }

    return customPath;
  }

  /// Sanitizes the [path] removing [find].
  ///
  /// Generally used to remove unnecessary parts of the path as {lib} or {test}.
  @visibleForTesting
  String sanitizePath(String path, [String find = 'lib/']) {
    if (!path.startsWith(find)) return path;

    return path.replaceFirst(find, '');
  }

  /// Sanitizes [_customConfig] to remove unnecessary {lib} or {test} from paths.
  ///
  /// Warns the user if the custom config has deprecated path parts.
  void _sanitizeCustomConfig() {
    final sanitizedConfig = _customConfig.copyWith(
      stackedAppFilePath: sanitizePath(_customConfig.stackedAppFilePath),
      servicesPath: sanitizePath(_customConfig.servicesPath),
      viewsPath: sanitizePath(_customConfig.viewsPath),
      testHelpersFilePath:
          sanitizePath(_customConfig.testHelpersFilePath, 'test/'),
      testServicesPath: sanitizePath(_customConfig.testServicesPath, 'test/'),
      testViewsPath: sanitizePath(_customConfig.testViewsPath, 'test/'),
    );

    if (_customConfig == sanitizedConfig) return;

    stdout.writeln(kDeprecatedPaths);

    _customConfig = sanitizedConfig;
  }

  /// Returns file path of test helpers and mock services relative to [path].
  @visibleForTesting
  String getFilePathToHelpersAndMocks(String path) {
    String fileToImport = testHelpersFilePath;
    final pathSegments =
        path.split('/').where((element) => !element.contains('.'));

    for (var i = 0; i < pathSegments.length; i++) {
      fileToImport = '../$fileToImport';
    }

    return fileToImport;
  }

  /// Exports custom config as a formatted Json String.
  String exportConfig() {
    return const JsonEncoder.withIndent("    ").convert(_customConfig.toJson());
  }

  /// Overrides [widgets_path] value on configuration.
  void setWidgetsPath(String? path) {
    _customConfig = _customConfig.copyWith(
      widgetsPath: path ?? _customConfig.widgetsPath,
    );
  }
}
