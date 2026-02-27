import 'dependency_config.dart';
import 'package:stacked_generator/src/generators/extensions/environments_extract_extension.dart';
import 'package:stacked_generator/src/generators/extensions/string_utils_extension.dart';

class FactoryDependency extends DependencyConfig {
  const FactoryDependency({
    required super.import,
    required super.className,
    super.abstractedImport,
    super.abstractedTypeClassName,
    super.environments,
    super.instanceName,
  });

  @override
  String registerDependencies(String locatorName) {
    return '$locatorName.registerFactory${abstractedTypeClassName.surroundWithAngleBracketsOrReturnEmptyIfNull}(() => $className()  ${environments.getFromatedEnvs}${instanceName.addInstanceNameIfNotNull});';
  }
}
