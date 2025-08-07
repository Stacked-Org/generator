import 'dependency_config.dart';
import 'package:stacked_generator/src/generators/extensions/environments_extract_extension.dart';
import 'package:stacked_generator/src/generators/extensions/string_utils_extension.dart';

class InitializableSingletonDependency extends DependencyConfig {
  const InitializableSingletonDependency({
    required super.import,
    required super.className,
    super.abstractedImport,
    super.abstractedTypeClassName,
    super.environments,
    super.instanceName,
  });

  @override
  String registerDependencies(String locatorName) {
    return '''
        final $camelCaseClassName = $className();
        await $camelCaseClassName.init();
        $locatorName.registerSingleton${abstractedTypeClassName.surroundWithAngleBracketsOrReturnEmptyIfNull}($camelCaseClassName  ${environments.getFromatedEnvs}${instanceName.addInstanceNameIfNotNull});
        ''';
  }
}
