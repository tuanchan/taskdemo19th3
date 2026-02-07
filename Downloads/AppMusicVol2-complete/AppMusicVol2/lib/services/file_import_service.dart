import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/song.dart';
import 'database_helper.dart';

class FileImportService {
  static final FileImportService instance = FileImportService._init();
  final _uuid = const Uuid();

  FileImportService._init();

  Future<List<Song>> importFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
      );

      if (result == null) return [];

      List<Song> importedSongs = [];

      for (var file in result.files) {
        if (file.path != null) {
          final song = await _processFile(file.path!);
          if (song != null) {
            importedSongs.add(song);
            await DatabaseHelper.instance.insertSong(song);
          }
        }
      }

      return importedSongs;
    } catch (e) {
      print('Error importing files: $e');
      return [];
    }
  }

  Future<List<Song>> importFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) return [];

      List<Song> importedSongs = [];
      final directory = Directory(selectedDirectory);
      
      await for (var entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          final song = await _processFile(entity.path);
          if (song != null) {
            importedSongs.add(song);
            await DatabaseHelper.instance.insertSong(song);
          }
        }
      }

      return importedSongs;
    } catch (e) {
      print('Error importing folder: $e');
      return [];
    }
  }

  Future<Map<String, List<Song>>> importFolderWithStructure() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) return {};

      Map<String, List<Song>> playlistsMap = {};
      final directory = Directory(selectedDirectory);
      
      await for (var entity in directory.list(recursive: false, followLinks: false)) {
        if (entity is Directory) {
          final folderName = entity.path.split('/').last;
          final songs = await _importFromDirectory(entity);
          if (songs.isNotEmpty) {
            playlistsMap[folderName] = songs;
          }
        } else if (entity is File && _isAudioFile(entity.path)) {
          final song = await _processFile(entity.path);
          if (song != null) {
            playlistsMap.putIfAbsent('Root', () => []).add(song);
            await DatabaseHelper.instance.insertSong(song);
          }
        }
      }

      return playlistsMap;
    } catch (e) {
      print('Error importing folder structure: $e');
      return {};
    }
  }

  Future<List<Song>> _importFromDirectory(Directory directory) async {
    List<Song> songs = [];
    
    await for (var entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File && _isAudioFile(entity.path)) {
        final song = await _processFile(entity.path);
        if (song != null) {
          songs.add(song);
          await DatabaseHelper.instance.insertSong(song);
        }
      }
    }

    return songs;
  }

  Future<Song?> _processFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      // Copy file to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = filePath.split('/').last;
      final newPath = '${appDir.path}/music/$fileName';
      
      final musicDir = Directory('${appDir.path}/music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      final newFile = await file.copy(newPath);

      // Extract metadata (simplified version)
      final title = fileName.replaceAll(RegExp(r'\.(mp3|m4a|wav|aac)$'), '');
      
      return Song(
        id: _uuid.v4(),
        title: title,
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        filePath: newFile.path,
        duration: 0, // Will be updated when played
        addedDate: DateTime.now(),
      );
    } catch (e) {
      print('Error processing file: $e');
      return null;
    }
  }

  bool _isAudioFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp3') ||
        ext.endsWith('.m4a') ||
        ext.endsWith('.wav') ||
        ext.endsWith('.aac');
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
