import 'dependency_config.dart';
import 'package:stacked_generator/src/generators/extensions/environments_extract_extension.dart';
import 'package:stacked_generator/src/generators/extensions/string_utils_extension.dart';

class PresolveSingletonDependency extends DependencyConfig {
  /// The static function to use for presolving the service
  final String? presolveFunction;

  const PresolveSingletonDependency({
    required super.import,
    required super.className,
    super.abstractedImport,
    super.abstractedTypeClassName,
    super.environments,
    this.presolveFunction,
    super.instanceName,
  });

  @override
  String registerDependencies(String locatorName) {
    return '''
        final $camelCaseClassName = await $className.$presolveFunction();
        $locatorName.registerSingleton${abstractedTypeClassName.surroundWithAngleBracketsOrReturnEmptyIfNull}($camelCaseClassName  ${environments.getFromatedEnvs}${instanceName.addInstanceNameIfNotNull});
        ''';
  }
}
