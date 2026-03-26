import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:stacked_generator/import_resolver.dart';
import 'package:stacked_generator/utils.dart';
import 'package:stacked_shared/stacked_shared.dart';

import 'dependency_config/factory_param_dependency.dart';

const _factoryParamChecker = TypeChecker.typeNamed(
  FactoryParam,
  inPackage: 'stacked_shared',
);

class DependencyParameterResolver {
  final ImportResolver _importResolver;

  const DependencyParameterResolver(this._importResolver);

  FactoryParameter resolve(FormalParameterElement parameterElement) {
    final paramType = parameterElement.type;

    final isFactoryParam = _factoryParamChecker.hasAnnotationOfExact(
      parameterElement,
    );
    return FactoryParameter(
      isFactoryParam: isFactoryParam,
      type: toDisplayString(paramType),
      name: (parameterElement.name ?? '').replaceFirst("_", ''),
      isPositional: parameterElement.isPositional,
      isRequired: !parameterElement.isOptional,
      defaultValueCode: parameterElement.defaultValueCode,
      imports: _importResolver.resolveAll(paramType),
    );
  }
}
