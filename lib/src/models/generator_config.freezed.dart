// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generator_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

GeneratorConfig _$GeneratorConfigFromJson(Map<String, dynamic> json) {
  return _GeneratorConfig.fromJson(json);
}

/// @nodoc
mixin _$GeneratorConfig {
  bool get navigator2 => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GeneratorConfigCopyWith<GeneratorConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratorConfigCopyWith<$Res> {
  factory $GeneratorConfigCopyWith(
          GeneratorConfig value, $Res Function(GeneratorConfig) then) =
      _$GeneratorConfigCopyWithImpl<$Res, GeneratorConfig>;
  @useResult
  $Res call({bool navigator2});
}

/// @nodoc
class _$GeneratorConfigCopyWithImpl<$Res, $Val extends GeneratorConfig>
    implements $GeneratorConfigCopyWith<$Res> {
  _$GeneratorConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? navigator2 = null,
  }) {
    return _then(_value.copyWith(
      navigator2: null == navigator2
          ? _value.navigator2
          : navigator2 // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeneratorConfigImplCopyWith<$Res>
    implements $GeneratorConfigCopyWith<$Res> {
  factory _$$GeneratorConfigImplCopyWith(_$GeneratorConfigImpl value,
          $Res Function(_$GeneratorConfigImpl) then) =
      __$$GeneratorConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool navigator2});
}

/// @nodoc
class __$$GeneratorConfigImplCopyWithImpl<$Res>
    extends _$GeneratorConfigCopyWithImpl<$Res, _$GeneratorConfigImpl>
    implements _$$GeneratorConfigImplCopyWith<$Res> {
  __$$GeneratorConfigImplCopyWithImpl(
      _$GeneratorConfigImpl _value, $Res Function(_$GeneratorConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? navigator2 = null,
  }) {
    return _then(_$GeneratorConfigImpl(
      navigator2: null == navigator2
          ? _value.navigator2
          : navigator2 // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeneratorConfigImpl implements _GeneratorConfig {
  _$GeneratorConfigImpl({this.navigator2 = false});

  factory _$GeneratorConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeneratorConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool navigator2;

  @override
  String toString() {
    return 'GeneratorConfig(navigator2: $navigator2)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratorConfigImpl &&
            (identical(other.navigator2, navigator2) ||
                other.navigator2 == navigator2));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, navigator2);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratorConfigImplCopyWith<_$GeneratorConfigImpl> get copyWith =>
      __$$GeneratorConfigImplCopyWithImpl<_$GeneratorConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeneratorConfigImplToJson(
      this,
    );
  }
}

abstract class _GeneratorConfig implements GeneratorConfig {
  factory _GeneratorConfig({final bool navigator2}) = _$GeneratorConfigImpl;

  factory _GeneratorConfig.fromJson(Map<String, dynamic> json) =
      _$GeneratorConfigImpl.fromJson;

  @override
  bool get navigator2;
  @override
  @JsonKey(ignore: true)
  _$$GeneratorConfigImplCopyWith<_$GeneratorConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
