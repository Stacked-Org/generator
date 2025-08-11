import 'package:test/test.dart';
import 'element2_mock_helper.dart';

void main() {
  group('Element2 Mock Helper Tests', () {
    test('createMockClassElement2 returns working ClassElement2 mock', () {
      // Test with default filename
      final mockElement = createMockClassElement2();
      final fileName = mockElement.firstFragment.libraryFragment.source.uri.pathSegments.last;
      
      expect(fileName, equals('test_app.dart'));
    });

    test('createMockClassElement2 supports custom filenames', () {
      // Test with custom filename
      const customFileName = 'home_view.dart';
      final mockElement = createMockClassElement2(fileName: customFileName);
      final fileName = mockElement.firstFragment.libraryFragment.source.uri.pathSegments.last;
      
      expect(fileName, equals(customFileName));
    });

    test('mock supports full property chain used by Router 2.0 generator', () {
      // Test the exact chain used in auto_route_generator.dart
      const testFileName = 'settings_view.dart';
      final mockElement = createMockClassElement2(fileName: testFileName);
      
      // This is the exact chain from the generator:
      // clazz.firstFragment.libraryFragment.source.uri.pathSegments.last
      final actualFileName = mockElement.firstFragment.libraryFragment.source.uri.pathSegments.last;
      final fullUri = mockElement.firstFragment.libraryFragment.source.uri;
      
      expect(actualFileName, equals(testFileName));
      expect(fullUri.toString(), equals('package:test_app/lib/$testFileName'));
      expect(fullUri.pathSegments, contains(testFileName));
    });

    test('mock supports URI access for preferRelativeImports check', () {
      // Test the targetFileUri assignment used in auto_route_generator.dart
      const testFileName = 'profile_view.dart';
      final mockElement = createMockClassElement2(fileName: testFileName);
      
      // This is used for preferRelativeImports in the generator:
      // targetFileUri = element.firstFragment.libraryFragment.source.uri;
      final targetFileUri = mockElement.firstFragment.libraryFragment.source.uri;
      
      expect(targetFileUri, isA<Uri>());
      expect(targetFileUri.toString(), contains(testFileName));
      expect(targetFileUri.scheme, equals('package'));
    });
  });
}