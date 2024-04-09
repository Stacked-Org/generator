// ignore_for_file: unnecessary_this

import 'package:analyzer/dart/element/element.dart';

/// Described a single field to be generated.
///
/// date pickers etc.
abstract class FieldConfig {
  /// The name of the form field. This will be used to generate the Key mapping
  final String name;

  const FieldConfig({required this.name});
}

class TextFieldConfig extends FieldConfig {
  final String? initialValue;
  final ExecutableElementData? validatorFunction;
  final ExecutableElementData? customTextEditingController;
  const TextFieldConfig({
    required super.name,
    this.initialValue,
    this.validatorFunction,
    this.customTextEditingController,
  });
}

class DateFieldConfig extends FieldConfig {
  const DateFieldConfig({required super.name});
}

class DropdownFieldConfig extends FieldConfig {
  final List<DropdownFieldItem> items;
  const DropdownFieldConfig({required super.name, required this.items});
}

class DropdownFieldItem {
  final String title;
  final String value;

  const DropdownFieldItem({required this.title, required this.value});
}

class ExecutableElementData {
  final String? validatorPath;
  final String? validatorName;
  final String? enclosingElementName;
  final bool hasEnclosingElementName;
  final String? returnType;
  const ExecutableElementData({
    this.validatorPath,
    this.validatorName,
    this.enclosingElementName,
    this.hasEnclosingElementName = false,
    this.returnType,
  });

  factory ExecutableElementData.fromExecutableElement(
      ExecutableElement executableElement) {
    return ExecutableElementData(
        returnType: executableElement.declaration.returnType.toString(),
        enclosingElementName: executableElement.enclosingElementName,
        hasEnclosingElementName: executableElement.hasEnclosingElementName,
        validatorName: executableElement.validatorName,
        validatorPath: executableElement.validatorPath);
  }
}

extension ListOfFieldConfigs on List<FieldConfig> {
  List<TextFieldConfig> get onlyTextFieldConfigs =>
      this.whereType<TextFieldConfig>().map((t) => t).toList();

  List<DateFieldConfig> get onlyDateFieldConfigs =>
      this.whereType<DateFieldConfig>().map((t) => t).toList();

  List<DropdownFieldConfig> get onlyDropdownFieldConfigs =>
      this.whereType<DropdownFieldConfig>().map((t) => t).toList();
}

extension ExecutableElementDataExtension on ExecutableElement? {
  String? get validatorPath => this?.source.uri.toString();
  String? get validatorName => hasEnclosingElementName
      ? '$enclosingElementName.${this?.name}'
      : this?.name;
  bool get hasEnclosingElementName => enclosingElementName != null;
  String? get enclosingElementName => this?.enclosingElement.name;
}
