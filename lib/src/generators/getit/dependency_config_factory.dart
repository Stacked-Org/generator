import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:stacked_generator/import_resolver.dart';
import 'package:stacked_generator/src/generators/getit/dependency_config/factory_dependency.dart';
import 'package:stacked_generator/src/generators/getit/dependency_config/presolve_singleton_dependency.dart';
import 'package:stacked_generator/src/generators/getit/dependency_config/singleton_dependency.dart';
import 'package:stacked_generator/src/generators/getit/stacked_locator_parameter_resolver.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../../../utils.dart';
import 'dependency_config/dependency_config.dart';
import 'dependency_config/factory_param_dependency.dart';
import 'dependency_config/initializable_singleton_dependency.dart';
import 'dependency_config/lazy_singleton.dart';

class DependencyConfigFactory {
  static DependencyConfig fromResolver({
    required DartObject dependencyConfig,
    required ImportResolver importResolver,
  }) {
    var dependencyReader = ConstantReader(dependencyConfig);
    // Get the type of the service that we want to register
    final DartType dependencyClassType =
        dependencyReader.read('classType').typeValue;

    final String? instanceName = dependencyReader.read('instanceName').isNull
        ? null
        : dependencyReader.read('instanceName').stringValue;

    final DartType? dependencyAbstractedClassType =
        dependencyReader.peek('asType')?.typeValue;

    final classElement = dependencyClassType.element3 as ClassElement2?;

    throwIf(
      classElement == null,
      '🛑 ${toDisplayString(dependencyClassType)} is not a class element. All services should be classes. We don\'t register individual values for global access through the locator. Make sure the value provided as your service type is a class.',
    );

    final Set<String>? environments = dependencyReader
        .peek('environments')
        ?.setValue
        .map((e) => e.toStringValue())
        .where((element) => element != null)
        .toSet()
        .cast<String>();

    // Get the import of the class type that's defined for the service
    final import = importResolver.resolve(classElement!);

    final abstractedClassElement =
        dependencyAbstractedClassType?.element3 as ClassElement2?;

    final abstractedImport = importResolver.resolve(abstractedClassElement);

    final className = toDisplayString(dependencyClassType);

    final abstractedTypeClassName = dependencyAbstractedClassType != null
        ? toDisplayString(dependencyAbstractedClassType)
        : null;

    // NOTE: This can be used for actual dependency inject. We do service location instead.
    final constructor = classElement.unnamedConstructor2;

    if (dependencyReader.instanceOf(const TypeChecker.typeNamed(Factory))) {
      return FactoryDependency(
        instanceName: instanceName,
        import: import!,
        className: className,
        abstractedTypeClassName: abstractedTypeClassName,
        abstractedImport: abstractedImport,
        environments: environments,
      );
    } else if (dependencyReader
        .instanceOf(const TypeChecker.typeNamed(Singleton))) {
      final ConstantReader? resolveUsing =
          dependencyReader.peek('resolveUsing');
      final resolveObject = resolveUsing?.objectValue.toFunctionValue2();

      return SingletonDependency(
          instanceName: instanceName,
          import: import!,
          className: className,
          abstractedTypeClassName: abstractedTypeClassName,
          abstractedImport: abstractedImport,
          environments: environments,
          resolveFunction: resolveObject?.displayName);
    } else if (dependencyReader
        .instanceOf(const TypeChecker.typeNamed(LazySingleton))) {
      final ConstantReader? resolveUsing =
          dependencyReader.peek('resolveUsing');
      final resolveObject = resolveUsing?.objectValue.toFunctionValue2();

      return LazySingletonDependency(
          instanceName: instanceName,
          import: import!,
          className: className,
          abstractedTypeClassName: abstractedTypeClassName,
          abstractedImport: abstractedImport,
          environments: environments,
          resolveFunction: resolveObject?.displayName);
    } else if (dependencyReader
        // ignore: deprecated_member_use
        .instanceOf(const TypeChecker.typeNamed(Presolve))) {
      final ConstantReader? presolveUsing =
          dependencyReader.peek('presolveUsing');
      final presolveObject = presolveUsing?.objectValue.toFunctionValue2();
      return PresolveSingletonDependency(
          instanceName: instanceName,
          import: import!,
          className: className,
          abstractedTypeClassName: abstractedTypeClassName,
          abstractedImport: abstractedImport,
          environments: environments,
          presolveFunction: presolveObject?.displayName);
    } else if (dependencyReader
        .instanceOf(const TypeChecker.typeNamed(InitializableSingleton))) {
      return InitializableSingletonDependency(
        instanceName: instanceName,
        import: import!,
        className: className,
        abstractedTypeClassName: abstractedTypeClassName,
        abstractedImport: abstractedImport,
        environments: environments,
      );
    } else if (dependencyReader
        .instanceOf(const TypeChecker.typeNamed(FactoryWithParam))) {
      final Set<FactoryParameter> clazzParams = {};
      var params = constructor?.formalParameters;
      if (params?.isNotEmpty == true && constructor != null) {
        final paramResolver = DependencyParameterResolver(importResolver);
        for (FormalParameterElement p in constructor.formalParameters) {
          clazzParams.add(paramResolver.resolve(p));
        }
      }
      return FactoryParamDependency(
          instanceName: instanceName,
          import: import!,
          className: className,
          abstractedTypeClassName: abstractedTypeClassName,
          abstractedImport: abstractedImport,
          environments: environments,
          params: clazzParams);
    } else {
      throw UnimplementedError(
        'This Dependency ${dependencyReader.typeValue} is not implemented yet upgrading stacked_generator package to the latest version may fix the issue',
      );
    }
  }
}
