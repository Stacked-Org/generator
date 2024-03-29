// Mocks generated by Mockito 5.4.4 from annotations
// in stacked_generator/test/helpers/mocks/test_helpers.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:io' as _i4;
import 'dart:typed_data' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;
import 'package:stacked_generator/src/helpers/config_helper.dart' as _i7;
import 'package:stacked_generator/src/helpers/file_helper.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFileHelper_0 extends _i1.SmartFake implements _i2.FileHelper {
  _FakeFileHelper_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FileHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFileHelper extends _i1.Mock implements _i2.FileHelper {
  @override
  _i3.Future<void> writeStringFile({
    required _i4.File? file,
    required String? fileContent,
    bool? verbose = false,
    _i2.FileModificationType? type = _i2.FileModificationType.Create,
    String? verboseMessage,
    bool? forceAppend = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #writeStringFile,
          [],
          {
            #file: file,
            #fileContent: fileContent,
            #verbose: verbose,
            #type: type,
            #verboseMessage: verboseMessage,
            #forceAppend: forceAppend,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> writeDataFile({
    required _i4.File? file,
    required _i5.Uint8List? fileContent,
    bool? verbose = false,
    _i2.FileModificationType? type = _i2.FileModificationType.Create,
    String? verboseMessage,
    bool? forceAppend = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #writeDataFile,
          [],
          {
            #file: file,
            #fileContent: fileContent,
            #verbose: verbose,
            #type: type,
            #verboseMessage: verboseMessage,
            #forceAppend: forceAppend,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> deleteFile({
    required String? filePath,
    bool? verbose = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteFile,
          [],
          {
            #filePath: filePath,
            #verbose: verbose,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> deleteFolder({required String? directoryPath}) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteFolder,
          [],
          {#directoryPath: directoryPath},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<bool> fileExists({required String? filePath}) =>
      (super.noSuchMethod(
        Invocation.method(
          #fileExists,
          [],
          {#filePath: filePath},
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i3.Future<String> readFileAsString({required String? filePath}) =>
      (super.noSuchMethod(
        Invocation.method(
          #readFileAsString,
          [],
          {#filePath: filePath},
        ),
        returnValue: _i3.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #readFileAsString,
            [],
            {#filePath: filePath},
          ),
        )),
        returnValueForMissingStub:
            _i3.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #readFileAsString,
            [],
            {#filePath: filePath},
          ),
        )),
      ) as _i3.Future<String>);

  @override
  _i3.Future<_i5.Uint8List> readAsBytes({required String? filePath}) =>
      (super.noSuchMethod(
        Invocation.method(
          #readAsBytes,
          [],
          {#filePath: filePath},
        ),
        returnValue: _i3.Future<_i5.Uint8List>.value(_i5.Uint8List(0)),
        returnValueForMissingStub:
            _i3.Future<_i5.Uint8List>.value(_i5.Uint8List(0)),
      ) as _i3.Future<_i5.Uint8List>);

  @override
  _i3.Future<List<String>> readFileAsLines({required String? filePath}) =>
      (super.noSuchMethod(
        Invocation.method(
          #readFileAsLines,
          [],
          {#filePath: filePath},
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);

  @override
  _i3.Future<void> removeSpecificFileLines({
    required String? filePath,
    required String? removedContent,
    String? type = r'kTemplateNameView',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeSpecificFileLines,
          [],
          {
            #filePath: filePath,
            #removedContent: removedContent,
            #type: type,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> removeLinesOnFile({
    required String? filePath,
    required List<int>? linesNumber,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeLinesOnFile,
          [],
          {
            #filePath: filePath,
            #linesNumber: linesNumber,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> removeTestHelperFunctionFromFile({
    required String? filePath,
    required String? serviceName,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeTestHelperFunctionFromFile,
          [],
          {
            #filePath: filePath,
            #serviceName: serviceName,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<List<_i4.FileSystemEntity>> getFilesInDirectory(
          {required String? directoryPath}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFilesInDirectory,
          [],
          {#directoryPath: directoryPath},
        ),
        returnValue: _i3.Future<List<_i4.FileSystemEntity>>.value(
            <_i4.FileSystemEntity>[]),
        returnValueForMissingStub: _i3.Future<List<_i4.FileSystemEntity>>.value(
            <_i4.FileSystemEntity>[]),
      ) as _i3.Future<List<_i4.FileSystemEntity>>);

  @override
  _i3.Future<List<String>> getFoldersInDirectory(
          {required String? directoryPath}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFoldersInDirectory,
          [],
          {#directoryPath: directoryPath},
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);
}

/// A class which mocks [ConfigHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockConfigHelper extends _i1.Mock implements _i7.ConfigHelper {
  @override
  _i2.FileHelper get fileHelper => (super.noSuchMethod(
        Invocation.getter(#fileHelper),
        returnValue: _FakeFileHelper_0(
          this,
          Invocation.getter(#fileHelper),
        ),
        returnValueForMissingStub: _FakeFileHelper_0(
          this,
          Invocation.getter(#fileHelper),
        ),
      ) as _i2.FileHelper);

  @override
  bool get hasCustomConfig => (super.noSuchMethod(
        Invocation.getter(#hasCustomConfig),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  String get serviceImportPath => (super.noSuchMethod(
        Invocation.getter(#serviceImportPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#serviceImportPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#serviceImportPath),
        ),
      ) as String);

  @override
  String get servicePath => (super.noSuchMethod(
        Invocation.getter(#servicePath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#servicePath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#servicePath),
        ),
      ) as String);

  @override
  String get locatorName => (super.noSuchMethod(
        Invocation.getter(#locatorName),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#locatorName),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#locatorName),
        ),
      ) as String);

  @override
  String get registerMocksFunction => (super.noSuchMethod(
        Invocation.getter(#registerMocksFunction),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#registerMocksFunction),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#registerMocksFunction),
        ),
      ) as String);

  @override
  String get serviceTestHelpersImport => (super.noSuchMethod(
        Invocation.getter(#serviceTestHelpersImport),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#serviceTestHelpersImport),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#serviceTestHelpersImport),
        ),
      ) as String);

  @override
  String get bottomSheetsPath => (super.noSuchMethod(
        Invocation.getter(#bottomSheetsPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#bottomSheetsPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#bottomSheetsPath),
        ),
      ) as String);

  @override
  String get bottomSheetBuilderFilePath => (super.noSuchMethod(
        Invocation.getter(#bottomSheetBuilderFilePath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#bottomSheetBuilderFilePath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#bottomSheetBuilderFilePath),
        ),
      ) as String);

  @override
  String get bottomSheetTypeFilePath => (super.noSuchMethod(
        Invocation.getter(#bottomSheetTypeFilePath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#bottomSheetTypeFilePath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#bottomSheetTypeFilePath),
        ),
      ) as String);

  @override
  String get dialogsPath => (super.noSuchMethod(
        Invocation.getter(#dialogsPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#dialogsPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#dialogsPath),
        ),
      ) as String);

  @override
  String get dialogBuilderFilePath => (super.noSuchMethod(
        Invocation.getter(#dialogBuilderFilePath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#dialogBuilderFilePath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#dialogBuilderFilePath),
        ),
      ) as String);

  @override
  String get dialogTypeFilePath => (super.noSuchMethod(
        Invocation.getter(#dialogTypeFilePath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#dialogTypeFilePath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#dialogTypeFilePath),
        ),
      ) as String);

  @override
  String get stackedAppFilePath => (super.noSuchMethod(
        Invocation.getter(#stackedAppFilePath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#stackedAppFilePath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#stackedAppFilePath),
        ),
      ) as String);

  @override
  String get testHelpersFilePath => (super.noSuchMethod(
        Invocation.getter(#testHelpersFilePath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#testHelpersFilePath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#testHelpersFilePath),
        ),
      ) as String);

  @override
  String get testServicesPath => (super.noSuchMethod(
        Invocation.getter(#testServicesPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#testServicesPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#testServicesPath),
        ),
      ) as String);

  @override
  String get testViewsPath => (super.noSuchMethod(
        Invocation.getter(#testViewsPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#testViewsPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#testViewsPath),
        ),
      ) as String);

  @override
  String get viewImportPath => (super.noSuchMethod(
        Invocation.getter(#viewImportPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#viewImportPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#viewImportPath),
        ),
      ) as String);

  @override
  String get viewPath => (super.noSuchMethod(
        Invocation.getter(#viewPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#viewPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#viewPath),
        ),
      ) as String);

  @override
  String get viewTestHelpersImport => (super.noSuchMethod(
        Invocation.getter(#viewTestHelpersImport),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#viewTestHelpersImport),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#viewTestHelpersImport),
        ),
      ) as String);

  @override
  String get widgetPath => (super.noSuchMethod(
        Invocation.getter(#widgetPath),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#widgetPath),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#widgetPath),
        ),
      ) as String);

  @override
  String get widgetTestHelpersImport => (super.noSuchMethod(
        Invocation.getter(#widgetTestHelpersImport),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#widgetTestHelpersImport),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.getter(#widgetTestHelpersImport),
        ),
      ) as String);

  @override
  bool get v1 => (super.noSuchMethod(
        Invocation.getter(#v1),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  int get lineLength => (super.noSuchMethod(
        Invocation.getter(#lineLength),
        returnValue: 0,
        returnValueForMissingStub: 0,
      ) as int);

  @override
  bool get preferWeb => (super.noSuchMethod(
        Invocation.getter(#preferWeb),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i3.Future<void> composeAndLoadConfigFile({
    String? configFilePath,
    String? projectPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #composeAndLoadConfigFile,
          [],
          {
            #configFilePath: configFilePath,
            #projectPath: projectPath,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<String> composeConfigFile({
    String? configFilePath,
    String? projectPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #composeConfigFile,
          [],
          {
            #configFilePath: configFilePath,
            #projectPath: projectPath,
          },
        ),
        returnValue: _i3.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #composeConfigFile,
            [],
            {
              #configFilePath: configFilePath,
              #projectPath: projectPath,
            },
          ),
        )),
        returnValueForMissingStub:
            _i3.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #composeConfigFile,
            [],
            {
              #configFilePath: configFilePath,
              #projectPath: projectPath,
            },
          ),
        )),
      ) as _i3.Future<String>);

  @override
  _i3.Future<void> loadConfig(String? configFilePath) => (super.noSuchMethod(
        Invocation.method(
          #loadConfig,
          [configFilePath],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  String replaceCustomPaths(String? path) => (super.noSuchMethod(
        Invocation.method(
          #replaceCustomPaths,
          [path],
        ),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #replaceCustomPaths,
            [path],
          ),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #replaceCustomPaths,
            [path],
          ),
        ),
      ) as String);

  @override
  String sanitizePath(
    String? path, [
    String? find = r'lib/',
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #sanitizePath,
          [
            path,
            find,
          ],
        ),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #sanitizePath,
            [
              path,
              find,
            ],
          ),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #sanitizePath,
            [
              path,
              find,
            ],
          ),
        ),
      ) as String);

  @override
  String getFilePathToHelpersAndMocks(String? path) => (super.noSuchMethod(
        Invocation.method(
          #getFilePathToHelpersAndMocks,
          [path],
        ),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #getFilePathToHelpersAndMocks,
            [path],
          ),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #getFilePathToHelpersAndMocks,
            [path],
          ),
        ),
      ) as String);

  @override
  String exportConfig() => (super.noSuchMethod(
        Invocation.method(
          #exportConfig,
          [],
        ),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #exportConfig,
            [],
          ),
        ),
        returnValueForMissingStub: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #exportConfig,
            [],
          ),
        ),
      ) as String);

  @override
  void setWidgetsPath(String? path) => super.noSuchMethod(
        Invocation.method(
          #setWidgetsPath,
          [path],
        ),
        returnValueForMissingStub: null,
      );
}
