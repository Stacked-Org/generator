// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_shared/stacked_shared.dart';

import '../../../../helpers/dumb_service.dart';

final presolvedsingletonLocator = StackedLocator.instance;

Future<void> setupPresolvedsingletonLocator(
    {String? environment, EnvironmentFilter? environmentFilter}) async {
// Register environments
  presolvedsingletonLocator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  final dumpService = await DumpService.presolve();
  presolvedsingletonLocator.registerSingleton(dumpService);
}
