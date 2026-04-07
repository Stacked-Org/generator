import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:stacked_generator/import_resolver.dart';
import 'package:stacked_generator/utils.dart';
import 'package:stacked_shared/stacked_shared.dart';

import 'logger_class_generator.dart';
import 'logger_config_resolver.dart';

class StackedLoggerGenerator extends GeneratorForAnnotation<StackedApp> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    var loggerResolver = LoggerConfigResolver();
    var libs = await buildStep.resolver.libraries.toList();
    var importResolver = ImportResolver(
      libs,
      elementSourceUri(element)?.path ?? '',
    );

    final loggerConfig = await loggerResolver.resolve(
      annotation,
      importResolver,
    );

    if (loggerConfig != null) {
      return LoggerClassGenerator(loggerConfig).generate();
    }

    return Future.value('');
  }
}
