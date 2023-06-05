import 'dependency_config.dart';
import 'package:stacked_generator/src/generators/extensions/environments_extract_extension.dart';
import 'package:stacked_generator/src/generators/extensions/string_utils_extension.dart';

class InitializableSingletonDependency extends DependencyConfig {
  const InitializableSingletonDependency({
    required String import,
    required String className,
    String? abstractedImport,
    String? abstractedTypeClassName,
    Set<String>? environments,
    String? instanceName,
  }) : super(
          instanceName: instanceName,
          import: import,
          className: className,
          abstractedImport: abstractedImport,
          abstractedTypeClassName: abstractedTypeClassName,
          environments: environments,
        );

  @override
  String registerDependencies(String locatorName) {
    return '''
        final $camelCaseClassName = $className();
        await $camelCaseClassName.init();
        $locatorName.registerSingleton${abstractedTypeClassName.surroundWithAngleBracketsOrReturnEmptyIfNull}($camelCaseClassName  ${environments.getFromatedEnvs}${instanceName.addInstanceNameIfNotNull});
        ''';
  }
}
