import 'dependency_config.dart';
import 'package:stacked_generator/src/generators/extensions/environments_extract_extension.dart';
import 'package:stacked_generator/src/generators/extensions/string_utils_extension.dart';

class LazySingletonDependency extends DependencyConfig {
  /// The static function to use for resolving a singleton instance
  final String? resolveFunction;

  const LazySingletonDependency({
    required super.import,
    required super.className,
    super.abstractedImport,
    super.abstractedTypeClassName,
    super.environments,
    this.resolveFunction,
    super.instanceName,
  });

  @override
  String registerDependencies(String locatorName) {
    final singletonInstanceToReturn = resolveFunction != null
        ? '$className.$resolveFunction()'
        : '$className()';
    return '$locatorName.registerLazySingleton${abstractedTypeClassName.surroundWithAngleBracketsOrReturnEmptyIfNull}(() => $singletonInstanceToReturn ${environments.getFromatedEnvs}${instanceName.addInstanceNameIfNotNull});';
  }
}
