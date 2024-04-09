import 'dart:isolate';

import 'package:stacked_generator/src/generators/logging/logger_builder.dart';
import 'package:stacked_generator/src/generators/logging/logger_config.dart';
import 'package:test/test.dart';

void main() {
  group('MultiOutputLogger -', () {
    test('correctly calls init on multi output loggers.', () async {
      final loggerBuilder = LoggerBuilder(
              loggerConfig: LoggerConfig(loggerOutputs: ['One', 'Two']))
          .addLoggerClassConstantBody()
          .addLoggerNameAndOutputs();

      final code = loggerBuilder.serializeStringBuffer;

      final uri = Uri.dataFromString(
        '''
        import "dart:isolate";
        import 'package:logger/logger.dart';

        const kReleaseMode = true;
        const kIsWeb = false;

        class One extends LogOutput {
          static bool initCalled = false;
          static bool destroyCalled = false;

          @override
          Future<void> init() async {
            initCalled = true;
            await super.init();
          }

          @override
          void output(OutputEvent event) {
          }

          @override
          Future<void> destroy() async {
            destroyCalled = true;
            await super.destroy();
          }
        }

        class Two extends LogOutput {
          static bool initCalled = false;
          static bool destroyCalled = false;

          @override
          Future<void> init() async {
            initCalled = true;
            await super.init();
          }

          @override
          void output(OutputEvent event) {
          }

          @override
          Future<void> destroy() async {
            destroyCalled = true;
            await super.destroy();
          }
        }

        $code

        void main(_, SendPort port) {
          final logger = getLogger('classname');
          logger.i('test');
          port.send([One.initCalled, One.destroyCalled, Two.initCalled, Two.destroyCalled].join('-'));
        }
        ''',
        mimeType: 'application/dart',
      );

      final port = ReceivePort();
      await Isolate.spawnUri(uri, [], port.sendPort);

      final String response = await port.first;
      expect(response, contains('true-false-true-false'));
    });

    test('correctly calls destroy on multi output loggers.', () async {
      final loggerBuilder = LoggerBuilder(
              loggerConfig: LoggerConfig(loggerOutputs: ['One', 'Two']))
          .addLoggerClassConstantBody()
          .addLoggerNameAndOutputs();

      final code = loggerBuilder.serializeStringBuffer;

      final uri = Uri.dataFromString(
        '''
        import "dart:isolate";
        import 'package:logger/logger.dart';

        const kReleaseMode = true;
        const kIsWeb = false;

        class One extends LogOutput {
          static bool initCalled = false;
          static bool destroyCalled = false;

          @override
          Future<void> init() async {
            initCalled = true;
            await super.init();
          }

          @override
          void output(OutputEvent event) {
          }

          @override
          Future<void> destroy() async {
            destroyCalled = true;
            await super.destroy();
          }
        }

        class Two extends LogOutput {
          static bool initCalled = false;
          static bool destroyCalled = false;

          @override
          Future<void> init() async {
            initCalled = true;
            await super.init();
          }

          @override
          void output(OutputEvent event) {
          }

          @override
          Future<void> destroy() async {
            destroyCalled = true;
            await super.destroy();
          }
        }

        $code

        Future<void> main(_, SendPort port) async {
          final logger = getLogger('classname');
          await logger.close();
          port.send([One.initCalled, One.destroyCalled, Two.initCalled, Two.destroyCalled].join('-'));
        }
        ''',
        mimeType: 'application/dart',
      );

      final port = ReceivePort();
      await Isolate.spawnUri(uri, [], port.sendPort);

      final String response = await port.first;
      expect(response, contains('true-true-true-true'));
    });
  });
}
