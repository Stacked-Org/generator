import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

extension SpecExtension on Spec {
  String get buildLibraryForClass {
    final library = Library((b) => b..body.add(this));

    final emitter = DartEmitter.scoped();
    final result =
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
            .format('${library.accept(emitter)}');
    //print(result);
    return result;
  }
}

extension SpecsExtension on Iterable<Spec> {
  String get buildLibraryForClass {
    final library = Library((b) => b..body.addAll(this));

    final emitter = DartEmitter.scoped();
    final result =
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
            .format('${library.accept(emitter)}');

    return result;
  }
}

extension ListExpressionExtension on Iterable<Expression> {
  String get buildLibraryForListExpression {
    final library = Library((b) => b..body.addAll(this));

    final emitter = DartEmitter.scoped();
    final result =
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
            .format('${library.accept(emitter)}');

    return result;
  }
}
