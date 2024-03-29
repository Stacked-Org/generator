// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stacked_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

StackedConfig _$StackedConfigFromJson(Map<String, dynamic> json) {
  return _StackedConfig.fromJson(json);
}

/// @nodoc
mixin _$StackedConfig {
  /// Path where views and viewmodels will be genereated.
  @JsonKey(name: 'views_path')
  String get viewsPath => throw _privateConstructorUsedError;

  /// Path where services will be genereated.
  @JsonKey(name: 'services_path')
  String get servicesPath => throw _privateConstructorUsedError;

  /// Path where widgets will be genereated.
  @JsonKey(name: 'widgets_path')
  String get widgetsPath => throw _privateConstructorUsedError;

  /// Path where bottom sheets will be genereated.
  @JsonKey(name: 'bottom_sheets_path')
  String get bottomSheetsPath => throw _privateConstructorUsedError;

  /// File path where BottomSheetType enum values are located.
  @JsonKey(name: 'bottom_sheet_type_file_path')
  String get bottomSheetTypeFilePath => throw _privateConstructorUsedError;

  /// File path where BottomSheet builders are located.
  @JsonKey(name: 'bottom_sheet_builder_file_path')
  String get bottomSheetBuilderFilePath => throw _privateConstructorUsedError;

  /// Path where dialogs will be genereated.
  @JsonKey(name: 'dialogs_path')
  String get dialogsPath => throw _privateConstructorUsedError;

  /// File path where DialogType enum values are located.
  @JsonKey(name: 'dialog_type_file_path')
  String get dialogTypeFilePath => throw _privateConstructorUsedError;

  /// File path where Dialog builders are located.
  @JsonKey(name: 'dialog_builder_file_path')
  String get dialogBuilderFilePath => throw _privateConstructorUsedError;

  /// File path where StackedApp is setup.
  @JsonKey(name: 'stacked_app_file_path')
  String get stackedAppFilePath => throw _privateConstructorUsedError;

  /// File path where register functions for unit test setup and mock
  /// declarations are located.
  @JsonKey(name: 'test_helpers_file_path')
  String get testHelpersFilePath => throw _privateConstructorUsedError;

  /// Paths where services unit tests will be genereated.
  @JsonKey(name: 'test_services_path')
  String get testServicesPath => throw _privateConstructorUsedError;

  /// Path where viewmodels unit tests will be genereated.
  @JsonKey(name: 'test_views_path')
  String get testViewsPath => throw _privateConstructorUsedError;

  /// Path where widget models unit tests will be genereated.
  @JsonKey(name: 'test_widgets_path')
  String get testWidgetsPath => throw _privateConstructorUsedError;

  /// The name of the locator to use when registering test mocks
  @JsonKey(name: 'locator_name')
  String get locatorName => throw _privateConstructorUsedError;

  /// The name of the function that registers the mock services for tests.
  ///
  /// This is used when creating a test file during the `create service` command
  @JsonKey(name: 'register_mocks_function')
  String get registerMocksFunction => throw _privateConstructorUsedError;

  /// Boolean value to determine view builder style
  ///
  /// This is used when creating a view file during `create view` command. By
  /// default, StackedView is used.
  @JsonKey(name: 'v1')
  bool get v1 => throw _privateConstructorUsedError;

  /// Defines the integer value to determine the line length when formatting
  /// the code.
  @JsonKey(name: 'line_length')
  int get lineLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'prefer_web')
  bool get preferWeb => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StackedConfigCopyWith<StackedConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StackedConfigCopyWith<$Res> {
  factory $StackedConfigCopyWith(
          StackedConfig value, $Res Function(StackedConfig) then) =
      _$StackedConfigCopyWithImpl<$Res, StackedConfig>;
  @useResult
  $Res call(
      {@JsonKey(name: 'views_path') String viewsPath,
      @JsonKey(name: 'services_path') String servicesPath,
      @JsonKey(name: 'widgets_path') String widgetsPath,
      @JsonKey(name: 'bottom_sheets_path') String bottomSheetsPath,
      @JsonKey(name: 'bottom_sheet_type_file_path')
      String bottomSheetTypeFilePath,
      @JsonKey(name: 'bottom_sheet_builder_file_path')
      String bottomSheetBuilderFilePath,
      @JsonKey(name: 'dialogs_path') String dialogsPath,
      @JsonKey(name: 'dialog_type_file_path') String dialogTypeFilePath,
      @JsonKey(name: 'dialog_builder_file_path') String dialogBuilderFilePath,
      @JsonKey(name: 'stacked_app_file_path') String stackedAppFilePath,
      @JsonKey(name: 'test_helpers_file_path') String testHelpersFilePath,
      @JsonKey(name: 'test_services_path') String testServicesPath,
      @JsonKey(name: 'test_views_path') String testViewsPath,
      @JsonKey(name: 'test_widgets_path') String testWidgetsPath,
      @JsonKey(name: 'locator_name') String locatorName,
      @JsonKey(name: 'register_mocks_function') String registerMocksFunction,
      @JsonKey(name: 'v1') bool v1,
      @JsonKey(name: 'line_length') int lineLength,
      @JsonKey(name: 'prefer_web') bool preferWeb});
}

/// @nodoc
class _$StackedConfigCopyWithImpl<$Res, $Val extends StackedConfig>
    implements $StackedConfigCopyWith<$Res> {
  _$StackedConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewsPath = null,
    Object? servicesPath = null,
    Object? widgetsPath = null,
    Object? bottomSheetsPath = null,
    Object? bottomSheetTypeFilePath = null,
    Object? bottomSheetBuilderFilePath = null,
    Object? dialogsPath = null,
    Object? dialogTypeFilePath = null,
    Object? dialogBuilderFilePath = null,
    Object? stackedAppFilePath = null,
    Object? testHelpersFilePath = null,
    Object? testServicesPath = null,
    Object? testViewsPath = null,
    Object? testWidgetsPath = null,
    Object? locatorName = null,
    Object? registerMocksFunction = null,
    Object? v1 = null,
    Object? lineLength = null,
    Object? preferWeb = null,
  }) {
    return _then(_value.copyWith(
      viewsPath: null == viewsPath
          ? _value.viewsPath
          : viewsPath // ignore: cast_nullable_to_non_nullable
              as String,
      servicesPath: null == servicesPath
          ? _value.servicesPath
          : servicesPath // ignore: cast_nullable_to_non_nullable
              as String,
      widgetsPath: null == widgetsPath
          ? _value.widgetsPath
          : widgetsPath // ignore: cast_nullable_to_non_nullable
              as String,
      bottomSheetsPath: null == bottomSheetsPath
          ? _value.bottomSheetsPath
          : bottomSheetsPath // ignore: cast_nullable_to_non_nullable
              as String,
      bottomSheetTypeFilePath: null == bottomSheetTypeFilePath
          ? _value.bottomSheetTypeFilePath
          : bottomSheetTypeFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      bottomSheetBuilderFilePath: null == bottomSheetBuilderFilePath
          ? _value.bottomSheetBuilderFilePath
          : bottomSheetBuilderFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      dialogsPath: null == dialogsPath
          ? _value.dialogsPath
          : dialogsPath // ignore: cast_nullable_to_non_nullable
              as String,
      dialogTypeFilePath: null == dialogTypeFilePath
          ? _value.dialogTypeFilePath
          : dialogTypeFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      dialogBuilderFilePath: null == dialogBuilderFilePath
          ? _value.dialogBuilderFilePath
          : dialogBuilderFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      stackedAppFilePath: null == stackedAppFilePath
          ? _value.stackedAppFilePath
          : stackedAppFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      testHelpersFilePath: null == testHelpersFilePath
          ? _value.testHelpersFilePath
          : testHelpersFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      testServicesPath: null == testServicesPath
          ? _value.testServicesPath
          : testServicesPath // ignore: cast_nullable_to_non_nullable
              as String,
      testViewsPath: null == testViewsPath
          ? _value.testViewsPath
          : testViewsPath // ignore: cast_nullable_to_non_nullable
              as String,
      testWidgetsPath: null == testWidgetsPath
          ? _value.testWidgetsPath
          : testWidgetsPath // ignore: cast_nullable_to_non_nullable
              as String,
      locatorName: null == locatorName
          ? _value.locatorName
          : locatorName // ignore: cast_nullable_to_non_nullable
              as String,
      registerMocksFunction: null == registerMocksFunction
          ? _value.registerMocksFunction
          : registerMocksFunction // ignore: cast_nullable_to_non_nullable
              as String,
      v1: null == v1
          ? _value.v1
          : v1 // ignore: cast_nullable_to_non_nullable
              as bool,
      lineLength: null == lineLength
          ? _value.lineLength
          : lineLength // ignore: cast_nullable_to_non_nullable
              as int,
      preferWeb: null == preferWeb
          ? _value.preferWeb
          : preferWeb // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StackedConfigImplCopyWith<$Res>
    implements $StackedConfigCopyWith<$Res> {
  factory _$$StackedConfigImplCopyWith(
          _$StackedConfigImpl value, $Res Function(_$StackedConfigImpl) then) =
      __$$StackedConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'views_path') String viewsPath,
      @JsonKey(name: 'services_path') String servicesPath,
      @JsonKey(name: 'widgets_path') String widgetsPath,
      @JsonKey(name: 'bottom_sheets_path') String bottomSheetsPath,
      @JsonKey(name: 'bottom_sheet_type_file_path')
      String bottomSheetTypeFilePath,
      @JsonKey(name: 'bottom_sheet_builder_file_path')
      String bottomSheetBuilderFilePath,
      @JsonKey(name: 'dialogs_path') String dialogsPath,
      @JsonKey(name: 'dialog_type_file_path') String dialogTypeFilePath,
      @JsonKey(name: 'dialog_builder_file_path') String dialogBuilderFilePath,
      @JsonKey(name: 'stacked_app_file_path') String stackedAppFilePath,
      @JsonKey(name: 'test_helpers_file_path') String testHelpersFilePath,
      @JsonKey(name: 'test_services_path') String testServicesPath,
      @JsonKey(name: 'test_views_path') String testViewsPath,
      @JsonKey(name: 'test_widgets_path') String testWidgetsPath,
      @JsonKey(name: 'locator_name') String locatorName,
      @JsonKey(name: 'register_mocks_function') String registerMocksFunction,
      @JsonKey(name: 'v1') bool v1,
      @JsonKey(name: 'line_length') int lineLength,
      @JsonKey(name: 'prefer_web') bool preferWeb});
}

/// @nodoc
class __$$StackedConfigImplCopyWithImpl<$Res>
    extends _$StackedConfigCopyWithImpl<$Res, _$StackedConfigImpl>
    implements _$$StackedConfigImplCopyWith<$Res> {
  __$$StackedConfigImplCopyWithImpl(
      _$StackedConfigImpl _value, $Res Function(_$StackedConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewsPath = null,
    Object? servicesPath = null,
    Object? widgetsPath = null,
    Object? bottomSheetsPath = null,
    Object? bottomSheetTypeFilePath = null,
    Object? bottomSheetBuilderFilePath = null,
    Object? dialogsPath = null,
    Object? dialogTypeFilePath = null,
    Object? dialogBuilderFilePath = null,
    Object? stackedAppFilePath = null,
    Object? testHelpersFilePath = null,
    Object? testServicesPath = null,
    Object? testViewsPath = null,
    Object? testWidgetsPath = null,
    Object? locatorName = null,
    Object? registerMocksFunction = null,
    Object? v1 = null,
    Object? lineLength = null,
    Object? preferWeb = null,
  }) {
    return _then(_$StackedConfigImpl(
      viewsPath: null == viewsPath
          ? _value.viewsPath
          : viewsPath // ignore: cast_nullable_to_non_nullable
              as String,
      servicesPath: null == servicesPath
          ? _value.servicesPath
          : servicesPath // ignore: cast_nullable_to_non_nullable
              as String,
      widgetsPath: null == widgetsPath
          ? _value.widgetsPath
          : widgetsPath // ignore: cast_nullable_to_non_nullable
              as String,
      bottomSheetsPath: null == bottomSheetsPath
          ? _value.bottomSheetsPath
          : bottomSheetsPath // ignore: cast_nullable_to_non_nullable
              as String,
      bottomSheetTypeFilePath: null == bottomSheetTypeFilePath
          ? _value.bottomSheetTypeFilePath
          : bottomSheetTypeFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      bottomSheetBuilderFilePath: null == bottomSheetBuilderFilePath
          ? _value.bottomSheetBuilderFilePath
          : bottomSheetBuilderFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      dialogsPath: null == dialogsPath
          ? _value.dialogsPath
          : dialogsPath // ignore: cast_nullable_to_non_nullable
              as String,
      dialogTypeFilePath: null == dialogTypeFilePath
          ? _value.dialogTypeFilePath
          : dialogTypeFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      dialogBuilderFilePath: null == dialogBuilderFilePath
          ? _value.dialogBuilderFilePath
          : dialogBuilderFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      stackedAppFilePath: null == stackedAppFilePath
          ? _value.stackedAppFilePath
          : stackedAppFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      testHelpersFilePath: null == testHelpersFilePath
          ? _value.testHelpersFilePath
          : testHelpersFilePath // ignore: cast_nullable_to_non_nullable
              as String,
      testServicesPath: null == testServicesPath
          ? _value.testServicesPath
          : testServicesPath // ignore: cast_nullable_to_non_nullable
              as String,
      testViewsPath: null == testViewsPath
          ? _value.testViewsPath
          : testViewsPath // ignore: cast_nullable_to_non_nullable
              as String,
      testWidgetsPath: null == testWidgetsPath
          ? _value.testWidgetsPath
          : testWidgetsPath // ignore: cast_nullable_to_non_nullable
              as String,
      locatorName: null == locatorName
          ? _value.locatorName
          : locatorName // ignore: cast_nullable_to_non_nullable
              as String,
      registerMocksFunction: null == registerMocksFunction
          ? _value.registerMocksFunction
          : registerMocksFunction // ignore: cast_nullable_to_non_nullable
              as String,
      v1: null == v1
          ? _value.v1
          : v1 // ignore: cast_nullable_to_non_nullable
              as bool,
      lineLength: null == lineLength
          ? _value.lineLength
          : lineLength // ignore: cast_nullable_to_non_nullable
              as int,
      preferWeb: null == preferWeb
          ? _value.preferWeb
          : preferWeb // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StackedConfigImpl implements _StackedConfig {
  _$StackedConfigImpl(
      {@JsonKey(name: 'views_path') this.viewsPath = 'ui/views',
      @JsonKey(name: 'services_path') this.servicesPath = 'services',
      @JsonKey(name: 'widgets_path') this.widgetsPath = 'ui/widgets/common',
      @JsonKey(name: 'bottom_sheets_path')
      this.bottomSheetsPath = 'ui/bottom_sheets',
      @JsonKey(name: 'bottom_sheet_type_file_path')
      this.bottomSheetTypeFilePath = 'enums/bottom_sheet_type.dart',
      @JsonKey(name: 'bottom_sheet_builder_file_path')
      this.bottomSheetBuilderFilePath = 'ui/setup/setup_bottom_sheet_ui.dart',
      @JsonKey(name: 'dialogs_path') this.dialogsPath = 'ui/dialogs',
      @JsonKey(name: 'dialog_type_file_path')
      this.dialogTypeFilePath = 'enums/dialog_type.dart',
      @JsonKey(name: 'dialog_builder_file_path')
      this.dialogBuilderFilePath = 'ui/setup/setup_dialog_ui.dart',
      @JsonKey(name: 'stacked_app_file_path')
      this.stackedAppFilePath = 'app/app.dart',
      @JsonKey(name: 'test_helpers_file_path')
      this.testHelpersFilePath = 'helpers/test_helpers.dart',
      @JsonKey(name: 'test_services_path') this.testServicesPath = 'services',
      @JsonKey(name: 'test_views_path') this.testViewsPath = 'viewmodels',
      @JsonKey(name: 'test_widgets_path')
      this.testWidgetsPath = 'widget_models',
      @JsonKey(name: 'locator_name') this.locatorName = 'locator',
      @JsonKey(name: 'register_mocks_function')
      this.registerMocksFunction = 'registerServices',
      @JsonKey(name: 'v1') this.v1 = false,
      @JsonKey(name: 'line_length') this.lineLength = 80,
      @JsonKey(name: 'prefer_web') this.preferWeb = false});

  factory _$StackedConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$StackedConfigImplFromJson(json);

  /// Path where views and viewmodels will be genereated.
  @override
  @JsonKey(name: 'views_path')
  final String viewsPath;

  /// Path where services will be genereated.
  @override
  @JsonKey(name: 'services_path')
  final String servicesPath;

  /// Path where widgets will be genereated.
  @override
  @JsonKey(name: 'widgets_path')
  final String widgetsPath;

  /// Path where bottom sheets will be genereated.
  @override
  @JsonKey(name: 'bottom_sheets_path')
  final String bottomSheetsPath;

  /// File path where BottomSheetType enum values are located.
  @override
  @JsonKey(name: 'bottom_sheet_type_file_path')
  final String bottomSheetTypeFilePath;

  /// File path where BottomSheet builders are located.
  @override
  @JsonKey(name: 'bottom_sheet_builder_file_path')
  final String bottomSheetBuilderFilePath;

  /// Path where dialogs will be genereated.
  @override
  @JsonKey(name: 'dialogs_path')
  final String dialogsPath;

  /// File path where DialogType enum values are located.
  @override
  @JsonKey(name: 'dialog_type_file_path')
  final String dialogTypeFilePath;

  /// File path where Dialog builders are located.
  @override
  @JsonKey(name: 'dialog_builder_file_path')
  final String dialogBuilderFilePath;

  /// File path where StackedApp is setup.
  @override
  @JsonKey(name: 'stacked_app_file_path')
  final String stackedAppFilePath;

  /// File path where register functions for unit test setup and mock
  /// declarations are located.
  @override
  @JsonKey(name: 'test_helpers_file_path')
  final String testHelpersFilePath;

  /// Paths where services unit tests will be genereated.
  @override
  @JsonKey(name: 'test_services_path')
  final String testServicesPath;

  /// Path where viewmodels unit tests will be genereated.
  @override
  @JsonKey(name: 'test_views_path')
  final String testViewsPath;

  /// Path where widget models unit tests will be genereated.
  @override
  @JsonKey(name: 'test_widgets_path')
  final String testWidgetsPath;

  /// The name of the locator to use when registering test mocks
  @override
  @JsonKey(name: 'locator_name')
  final String locatorName;

  /// The name of the function that registers the mock services for tests.
  ///
  /// This is used when creating a test file during the `create service` command
  @override
  @JsonKey(name: 'register_mocks_function')
  final String registerMocksFunction;

  /// Boolean value to determine view builder style
  ///
  /// This is used when creating a view file during `create view` command. By
  /// default, StackedView is used.
  @override
  @JsonKey(name: 'v1')
  final bool v1;

  /// Defines the integer value to determine the line length when formatting
  /// the code.
  @override
  @JsonKey(name: 'line_length')
  final int lineLength;
  @override
  @JsonKey(name: 'prefer_web')
  final bool preferWeb;

  @override
  String toString() {
    return 'StackedConfig(viewsPath: $viewsPath, servicesPath: $servicesPath, widgetsPath: $widgetsPath, bottomSheetsPath: $bottomSheetsPath, bottomSheetTypeFilePath: $bottomSheetTypeFilePath, bottomSheetBuilderFilePath: $bottomSheetBuilderFilePath, dialogsPath: $dialogsPath, dialogTypeFilePath: $dialogTypeFilePath, dialogBuilderFilePath: $dialogBuilderFilePath, stackedAppFilePath: $stackedAppFilePath, testHelpersFilePath: $testHelpersFilePath, testServicesPath: $testServicesPath, testViewsPath: $testViewsPath, testWidgetsPath: $testWidgetsPath, locatorName: $locatorName, registerMocksFunction: $registerMocksFunction, v1: $v1, lineLength: $lineLength, preferWeb: $preferWeb)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StackedConfigImpl &&
            (identical(other.viewsPath, viewsPath) ||
                other.viewsPath == viewsPath) &&
            (identical(other.servicesPath, servicesPath) ||
                other.servicesPath == servicesPath) &&
            (identical(other.widgetsPath, widgetsPath) ||
                other.widgetsPath == widgetsPath) &&
            (identical(other.bottomSheetsPath, bottomSheetsPath) ||
                other.bottomSheetsPath == bottomSheetsPath) &&
            (identical(
                    other.bottomSheetTypeFilePath, bottomSheetTypeFilePath) ||
                other.bottomSheetTypeFilePath == bottomSheetTypeFilePath) &&
            (identical(other.bottomSheetBuilderFilePath,
                    bottomSheetBuilderFilePath) ||
                other.bottomSheetBuilderFilePath ==
                    bottomSheetBuilderFilePath) &&
            (identical(other.dialogsPath, dialogsPath) ||
                other.dialogsPath == dialogsPath) &&
            (identical(other.dialogTypeFilePath, dialogTypeFilePath) ||
                other.dialogTypeFilePath == dialogTypeFilePath) &&
            (identical(other.dialogBuilderFilePath, dialogBuilderFilePath) ||
                other.dialogBuilderFilePath == dialogBuilderFilePath) &&
            (identical(other.stackedAppFilePath, stackedAppFilePath) ||
                other.stackedAppFilePath == stackedAppFilePath) &&
            (identical(other.testHelpersFilePath, testHelpersFilePath) ||
                other.testHelpersFilePath == testHelpersFilePath) &&
            (identical(other.testServicesPath, testServicesPath) ||
                other.testServicesPath == testServicesPath) &&
            (identical(other.testViewsPath, testViewsPath) ||
                other.testViewsPath == testViewsPath) &&
            (identical(other.testWidgetsPath, testWidgetsPath) ||
                other.testWidgetsPath == testWidgetsPath) &&
            (identical(other.locatorName, locatorName) ||
                other.locatorName == locatorName) &&
            (identical(other.registerMocksFunction, registerMocksFunction) ||
                other.registerMocksFunction == registerMocksFunction) &&
            (identical(other.v1, v1) || other.v1 == v1) &&
            (identical(other.lineLength, lineLength) ||
                other.lineLength == lineLength) &&
            (identical(other.preferWeb, preferWeb) ||
                other.preferWeb == preferWeb));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        viewsPath,
        servicesPath,
        widgetsPath,
        bottomSheetsPath,
        bottomSheetTypeFilePath,
        bottomSheetBuilderFilePath,
        dialogsPath,
        dialogTypeFilePath,
        dialogBuilderFilePath,
        stackedAppFilePath,
        testHelpersFilePath,
        testServicesPath,
        testViewsPath,
        testWidgetsPath,
        locatorName,
        registerMocksFunction,
        v1,
        lineLength,
        preferWeb
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StackedConfigImplCopyWith<_$StackedConfigImpl> get copyWith =>
      __$$StackedConfigImplCopyWithImpl<_$StackedConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StackedConfigImplToJson(
      this,
    );
  }
}

abstract class _StackedConfig implements StackedConfig {
  factory _StackedConfig(
      {@JsonKey(name: 'views_path') final String viewsPath,
      @JsonKey(name: 'services_path') final String servicesPath,
      @JsonKey(name: 'widgets_path') final String widgetsPath,
      @JsonKey(name: 'bottom_sheets_path') final String bottomSheetsPath,
      @JsonKey(name: 'bottom_sheet_type_file_path')
      final String bottomSheetTypeFilePath,
      @JsonKey(name: 'bottom_sheet_builder_file_path')
      final String bottomSheetBuilderFilePath,
      @JsonKey(name: 'dialogs_path') final String dialogsPath,
      @JsonKey(name: 'dialog_type_file_path') final String dialogTypeFilePath,
      @JsonKey(name: 'dialog_builder_file_path')
      final String dialogBuilderFilePath,
      @JsonKey(name: 'stacked_app_file_path') final String stackedAppFilePath,
      @JsonKey(name: 'test_helpers_file_path') final String testHelpersFilePath,
      @JsonKey(name: 'test_services_path') final String testServicesPath,
      @JsonKey(name: 'test_views_path') final String testViewsPath,
      @JsonKey(name: 'test_widgets_path') final String testWidgetsPath,
      @JsonKey(name: 'locator_name') final String locatorName,
      @JsonKey(name: 'register_mocks_function')
      final String registerMocksFunction,
      @JsonKey(name: 'v1') final bool v1,
      @JsonKey(name: 'line_length') final int lineLength,
      @JsonKey(name: 'prefer_web') final bool preferWeb}) = _$StackedConfigImpl;

  factory _StackedConfig.fromJson(Map<String, dynamic> json) =
      _$StackedConfigImpl.fromJson;

  @override

  /// Path where views and viewmodels will be genereated.
  @JsonKey(name: 'views_path')
  String get viewsPath;
  @override

  /// Path where services will be genereated.
  @JsonKey(name: 'services_path')
  String get servicesPath;
  @override

  /// Path where widgets will be genereated.
  @JsonKey(name: 'widgets_path')
  String get widgetsPath;
  @override

  /// Path where bottom sheets will be genereated.
  @JsonKey(name: 'bottom_sheets_path')
  String get bottomSheetsPath;
  @override

  /// File path where BottomSheetType enum values are located.
  @JsonKey(name: 'bottom_sheet_type_file_path')
  String get bottomSheetTypeFilePath;
  @override

  /// File path where BottomSheet builders are located.
  @JsonKey(name: 'bottom_sheet_builder_file_path')
  String get bottomSheetBuilderFilePath;
  @override

  /// Path where dialogs will be genereated.
  @JsonKey(name: 'dialogs_path')
  String get dialogsPath;
  @override

  /// File path where DialogType enum values are located.
  @JsonKey(name: 'dialog_type_file_path')
  String get dialogTypeFilePath;
  @override

  /// File path where Dialog builders are located.
  @JsonKey(name: 'dialog_builder_file_path')
  String get dialogBuilderFilePath;
  @override

  /// File path where StackedApp is setup.
  @JsonKey(name: 'stacked_app_file_path')
  String get stackedAppFilePath;
  @override

  /// File path where register functions for unit test setup and mock
  /// declarations are located.
  @JsonKey(name: 'test_helpers_file_path')
  String get testHelpersFilePath;
  @override

  /// Paths where services unit tests will be genereated.
  @JsonKey(name: 'test_services_path')
  String get testServicesPath;
  @override

  /// Path where viewmodels unit tests will be genereated.
  @JsonKey(name: 'test_views_path')
  String get testViewsPath;
  @override

  /// Path where widget models unit tests will be genereated.
  @JsonKey(name: 'test_widgets_path')
  String get testWidgetsPath;
  @override

  /// The name of the locator to use when registering test mocks
  @JsonKey(name: 'locator_name')
  String get locatorName;
  @override

  /// The name of the function that registers the mock services for tests.
  ///
  /// This is used when creating a test file during the `create service` command
  @JsonKey(name: 'register_mocks_function')
  String get registerMocksFunction;
  @override

  /// Boolean value to determine view builder style
  ///
  /// This is used when creating a view file during `create view` command. By
  /// default, StackedView is used.
  @JsonKey(name: 'v1')
  bool get v1;
  @override

  /// Defines the integer value to determine the line length when formatting
  /// the code.
  @JsonKey(name: 'line_length')
  int get lineLength;
  @override
  @JsonKey(name: 'prefer_web')
  bool get preferWeb;
  @override
  @JsonKey(ignore: true)
  _$$StackedConfigImplCopyWith<_$StackedConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
