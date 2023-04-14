import 'package:code_builder/code_builder.dart';
import 'package:stacked_generator/src/generators/router_common/models/route_config.dart';

import 'router_extension_builder_helper.dart';

class RouterExtensionBuilder with RouterExtensionBuilderHelper {
  final List<RouteConfig> routes;
  const RouterExtensionBuilder({required this.routes});

  Extension build(DartEmitter emitter) {
    return Extension(
      (b) => b
        ..name = 'RouterStateExtension'
        ..on = const Reference(
          'RouterService',
          'package:stacked_services/stacked_services.dart',
        )
        ..methods.addAll(buildNavigateToExtensionMethods(routes, emitter)),
    );
  }
}
