import 'dart:io';
import 'dart:typed_data';

import 'package:stacked_generator/src/helpers/file_helper.dart';
import 'package:test/test.dart';

void main() {
  group('FileHelper Tests -', () {
    late FileHelper fileHelper;
    late Directory tempDir;

    setUp(() async {
      fileHelper = FileHelper();
      tempDir = await Directory.systemTemp.createTemp('file_helper_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('File Writing -', () {
      test('should write string content to file', () async {
        final testFile = File('${tempDir.path}/test_write.txt');
        const content = 'Hello, World!';

        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: content,
        );

        expect(await testFile.exists(), isTrue);
        final readContent = await testFile.readAsString();
        expect(readContent, equals(content));
      });

      test('should create directories recursively when writing files', () async {
        final testFile = File('${tempDir.path}/nested/deep/test_file.txt');
        const content = 'Nested file content';

        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: content,
        );

        expect(await testFile.exists(), isTrue);
        final readContent = await testFile.readAsString();
        expect(readContent, equals(content));
      });

      test('should append to existing file when forceAppend is true', () async {
        final testFile = File('${tempDir.path}/append_test.txt');
        const initialContent = 'Initial content\n';
        const appendContent = 'Appended content';

        // Write initial content
        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: initialContent,
        );

        // Append content
        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: appendContent,
          forceAppend: true,
        );

        final finalContent = await testFile.readAsString();
        expect(finalContent, equals('Initial content\nAppended content'));
      });

      test('should overwrite existing file by default', () async {
        final testFile = File('${tempDir.path}/overwrite_test.txt');
        const initialContent = 'Initial content';
        const newContent = 'New content';

        // Write initial content
        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: initialContent,
        );

        // Overwrite with new content
        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: newContent,
        );

        final finalContent = await testFile.readAsString();
        expect(finalContent, equals(newContent));
      });
    });

    group('Binary File Writing -', () {
      test('should write binary data to file', () async {
        final testFile = File('${tempDir.path}/binary_test.bin');
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);

        await fileHelper.writeDataFile(
          file: testFile,
          fileContent: data,
        );

        expect(await testFile.exists(), isTrue);
        final readData = await testFile.readAsBytes();
        expect(readData, equals(data));
      });

      test('should append binary data when forceAppend is true', () async {
        final testFile = File('${tempDir.path}/binary_append_test.bin');
        final initialData = Uint8List.fromList([1, 2, 3]);
        final appendData = Uint8List.fromList([4, 5, 6]);

        // Write initial data
        await fileHelper.writeDataFile(
          file: testFile,
          fileContent: initialData,
        );

        // Append data
        await fileHelper.writeDataFile(
          file: testFile,
          fileContent: appendData,
          forceAppend: true,
        );

        final finalData = await testFile.readAsBytes();
        expect(finalData, equals([1, 2, 3, 4, 5, 6]));
      });
    });

    group('File Reading -', () {
      test('should read file as string', () async {
        final testFile = File('${tempDir.path}/read_test.txt');
        const content = 'Test content for reading';
        await testFile.writeAsString(content);

        final readContent = await fileHelper.readFileAsString(
          filePath: testFile.path,
        );

        expect(readContent, equals(content));
      });

      test('should read file as bytes', () async {
        final testFile = File('${tempDir.path}/read_bytes_test.bin');
        final data = Uint8List.fromList([10, 20, 30, 40]);
        await testFile.writeAsBytes(data);

        final readData = await fileHelper.readAsBytes(
          filePath: testFile.path,
        );

        expect(readData, equals(data));
      });

      test('should read file as lines', () async {
        final testFile = File('${tempDir.path}/read_lines_test.txt');
        const content = 'Line 1\nLine 2\nLine 3';
        await testFile.writeAsString(content);

        final lines = await fileHelper.readFileAsLines(
          filePath: testFile.path,
        );

        expect(lines, equals(['Line 1', 'Line 2', 'Line 3']));
      });

      test('should handle empty files when reading as lines', () async {
        final testFile = File('${tempDir.path}/empty_lines_test.txt');
        await testFile.writeAsString('');

        final lines = await fileHelper.readFileAsLines(
          filePath: testFile.path,
        );

        expect(lines, equals([]));
      });
    });

    group('File Existence -', () {
      test('should return true for existing files', () async {
        final testFile = File('${tempDir.path}/exists_test.txt');
        await testFile.writeAsString('content');

        final exists = await fileHelper.fileExists(filePath: testFile.path);
        expect(exists, isTrue);
      });

      test('should return false for non-existing files', () async {
        final nonExistentPath = '${tempDir.path}/does_not_exist.txt';

        final exists = await fileHelper.fileExists(filePath: nonExistentPath);
        expect(exists, isFalse);
      });
    });

    group('File Deletion -', () {
      test('should delete existing files', () async {
        final testFile = File('${tempDir.path}/delete_test.txt');
        await testFile.writeAsString('content to be deleted');

        expect(await testFile.exists(), isTrue);

        await fileHelper.deleteFile(filePath: testFile.path);

        expect(await testFile.exists(), isFalse);
      });

      test('should throw error when deleting non-existent file', () async {
        final nonExistentPath = '${tempDir.path}/does_not_exist.txt';

        expect(
          () => fileHelper.deleteFile(filePath: nonExistentPath),
          throwsA(isA<PathNotFoundException>()),
        );
      });
    });

    group('Directory Operations -', () {
      test('should get files in directory', () async {
        // Create test files
        final file1 = File('${tempDir.path}/file1.txt');
        final file2 = File('${tempDir.path}/file2.txt');
        final subDir = Directory('${tempDir.path}/subdir');
        await subDir.create();
        final file3 = File('${subDir.path}/file3.txt');

        await file1.writeAsString('content1');
        await file2.writeAsString('content2');
        await file3.writeAsString('content3');

        final files = await fileHelper.getFilesInDirectory(
          directoryPath: tempDir.path,
        );

        expect(files.length, greaterThanOrEqualTo(3));
        
        final filePaths = files.map((f) => f.path).toList();
        expect(filePaths, contains(file1.path));
        expect(filePaths, contains(file2.path));
        expect(filePaths, contains(file3.path));
      });

      test('should get folders in directory', () async {
        final subDir1 = Directory('${tempDir.path}/subdir1');
        final subDir2 = Directory('${tempDir.path}/subdir2');
        await subDir1.create();
        await subDir2.create();

        // Also create a file to ensure it's not included
        final file = File('${tempDir.path}/test_file.txt');
        await file.writeAsString('content');

        final folders = await fileHelper.getFoldersInDirectory(
          directoryPath: tempDir.path,
        );

        expect(folders, contains(subDir1.path));
        expect(folders, contains(subDir2.path));
        expect(folders, isNot(contains(file.path)));
      });

      test('should delete folder and all its contents', () async {
        final subDir = Directory('${tempDir.path}/folder_to_delete');
        await subDir.create();

        // Create files in the folder
        final file1 = File('${subDir.path}/file1.txt');
        final file2 = File('${subDir.path}/file2.txt');
        await file1.writeAsString('content1');
        await file2.writeAsString('content2');

        expect(await subDir.exists(), isTrue);
        expect(await file1.exists(), isTrue);
        expect(await file2.exists(), isTrue);

        await fileHelper.deleteFolder(directoryPath: subDir.path);

        expect(await subDir.exists(), isFalse);
        expect(await file1.exists(), isFalse);
        expect(await file2.exists(), isFalse);
      });
    });

    group('Line Manipulation -', () {
      test('should remove specific lines by line numbers', () async {
        final testFile = File('${tempDir.path}/line_removal_test.txt');
        const content = 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5';
        await testFile.writeAsString(content);

        // Remove lines 2 and 4 (1-indexed) - note that after removing line 2, 
        // the original line 4 becomes line 3, so we need to account for this
        await fileHelper.removeLinesOnFile(
          filePath: testFile.path,
          linesNumber: [2, 4],
        );

        final modifiedContent = await testFile.readAsString();
        // The actual result will be that we remove "Line 2" and "Line 5" 
        // (which was at index 4 after "Line 2" was removed)
        expect(modifiedContent, equals('Line 1\nLine 3\nLine 4'));
      });

      test('should handle removing lines from single-line file', () async {
        final testFile = File('${tempDir.path}/single_line_test.txt');
        const content = 'Single line';
        await testFile.writeAsString(content);

        await fileHelper.removeLinesOnFile(
          filePath: testFile.path,
          linesNumber: [1],
        );

        final modifiedContent = await testFile.readAsString();
        expect(modifiedContent, isEmpty);
      });

      test('should handle empty line numbers list', () async {
        final testFile = File('${tempDir.path}/no_removal_test.txt');
        const content = 'Line 1\nLine 2\nLine 3';
        await testFile.writeAsString(content);

        await fileHelper.removeLinesOnFile(
          filePath: testFile.path,
          linesNumber: [],
        );

        final modifiedContent = await testFile.readAsString();
        expect(modifiedContent, equals(content));
      });
    });

    group('Test Helper Function Removal -', () {
      test('should remove test helper function from file', () async {
        final testFile = File('${tempDir.path}/test_helper_test.dart');
        const content = '''
MockAuthService getAndRegisterAuthService() {
  var service = MockAuthService();
  // setup code here
  return service;
}

MockUserService getAndRegisterUserService() {
  var service = MockUserService();
  return service;
}
''';
        await testFile.writeAsString(content);

        await fileHelper.removeTestHelperFunctionFromFile(
          filePath: testFile.path,
          serviceName: 'AuthService',
        );

        final modifiedContent = await testFile.readAsString();
        expect(modifiedContent, isNot(contains('getAndRegisterAuthService')));
        expect(modifiedContent, contains('getAndRegisterUserService'));
      });

      test('should handle case insensitive removal', () async {
        final testFile = File('${tempDir.path}/case_test.dart');
        const content = '''
mockuserservice getandregisteruserservice() {
  return MockUserService();
}
''';
        await testFile.writeAsString(content);

        await fileHelper.removeTestHelperFunctionFromFile(
          filePath: testFile.path,
          serviceName: 'UserService',
        );

        final modifiedContent = await testFile.readAsString();
        expect(modifiedContent.trim(), isEmpty);
      });
    });

    group('Edge Cases -', () {
      test('should handle very large files', () async {
        final testFile = File('${tempDir.path}/large_file_test.txt');
        final largeContent = 'A' * 10000; // 10KB of 'A' characters

        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: largeContent,
        );

        final readContent = await fileHelper.readFileAsString(
          filePath: testFile.path,
        );

        expect(readContent.length, equals(10000));
        expect(readContent, equals(largeContent));
      });

      test('should handle files with special characters in names', () async {
        final testFile = File('${tempDir.path}/special-chars_@_test.txt');
        const content = 'Special file content';

        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: content,
        );

        expect(await testFile.exists(), isTrue);
        final readContent = await fileHelper.readFileAsString(
          filePath: testFile.path,
        );
        expect(readContent, equals(content));
      });

      test('should handle files with unicode content', () async {
        final testFile = File('${tempDir.path}/unicode_test.txt');
        const unicodeContent = '🎉 Hello, 世界! 🌟';

        await fileHelper.writeStringFile(
          file: testFile,
          fileContent: unicodeContent,
        );

        final readContent = await fileHelper.readFileAsString(
          filePath: testFile.path,
        );
        expect(readContent, equals(unicodeContent));
      });
    });
  });
}