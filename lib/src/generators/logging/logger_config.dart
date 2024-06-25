/// Described the logger functionality to generate in the app
class LoggerConfig {
  /// The name of the globally accessible function to return an instance of your Logger
  final String logHelperName;
  final Set<String> imports;
  final List<String> loggerOutputs;

  /// When set to true, console logs will not be printed in release mode
  /// Default is true
  final bool disableReleaseConsoleOutput;

  /// When set to true, console logs will not be printed while running unit
  /// tests or integration tests
  ///
  /// Default is false
  final bool disableTestsConsoleOutput;

  LoggerConfig({
    this.imports = const {},
    this.loggerOutputs = const [],
    this.logHelperName = 'getLogger',
    this.disableReleaseConsoleOutput = true,
    this.disableTestsConsoleOutput = false,
  });
}
