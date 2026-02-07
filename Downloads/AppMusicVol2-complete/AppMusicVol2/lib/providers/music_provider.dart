import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/database_helper.dart';
import '../services/audio_player_service.dart';
import '../services/file_import_service.dart';

class MusicProvider extends ChangeNotifier {
  List<Song> _allSongs = [];
  List<Song> _favoriteSongs = [];
  List<Playlist> _playlists = [];
  bool _isLoading = false;

  List<Song> get allSongs => _allSongs;
  List<Song> get favoriteSongs => _favoriteSongs;
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;

  final _audioService = AudioPlayerService.instance;
  final _dbHelper = DatabaseHelper.instance;
  final _fileService = FileImportService.instance;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSongs = await _dbHelper.getAllSongs();
      _favoriteSongs = await _dbHelper.getFavoriteSongs();
      _playlists = await _dbHelper.getAllPlaylists();
    } catch (e) {
      print('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> importFiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final songs = await _fileService.importFiles();
      await loadData();
    } catch (e) {
      print('Error importing files: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> importFolder() async {
    _isLoading = true;
    notifyListeners();

    try {
      final songs = await _fileService.importFolder();
      await loadData();
    } catch (e) {
      print('Error importing folder: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> importFolderWithPlaylists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final playlistsMap = await _fileService.importFolderWithStructure();
      
      for (var entry in playlistsMap.entries) {
        final playlist = Playlist(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: entry.key,
          createdDate: DateTime.now(),
          songIds: entry.value.map((s) => s.id).toList(),
        );
        await _dbHelper.insertPlaylist(playlist);
      }
      
      await loadData();
    } catch (e) {
      print('Error importing folder with playlists: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(Song song) async {
    try {
      await _dbHelper.toggleFavorite(song.id);
      await loadData();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> deleteSong(Song song) async {
    try {
      await _dbHelper.deleteSong(song.id);
      await _fileService.deleteFile(song.filePath);
      await loadData();
    } catch (e) {
      print('Error deleting song: $e');
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdDate: DateTime.now(),
      );
      await _dbHelper.insertPlaylist(playlist);
      await loadData();
    } catch (e) {
      print('Error creating playlist: $e');
    }
  }

  Future<void> addToPlaylist(String playlistId, String songId) async {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      if (!playlist.songIds.contains(songId)) {
        playlist.songIds.add(songId);
        await _dbHelper.updatePlaylist(playlist);
        await loadData();
      }
    } catch (e) {
      print('Error adding to playlist: $e');
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String songId) async {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      playlist.songIds.remove(songId);
      await _dbHelper.updatePlaylist(playlist);
      await loadData();
    } catch (e) {
      print('Error removing from playlist: $e');
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _dbHelper.deletePlaylist(playlistId);
      await loadData();
    } catch (e) {
      print('Error deleting playlist: $e');
    }
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      playlist.name = newName;
      await _dbHelper.updatePlaylist(playlist);
      await loadData();
    } catch (e) {
      print('Error renaming playlist: $e');
    }
  }

  List<Song> getPlaylistSongs(String playlistId) {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      return _allSongs.where((s) => playlist.songIds.contains(s.id)).toList();
    } catch (e) {
      return [];
    }
  }

  void playAll() {
    if (_allSongs.isNotEmpty) {
      _audioService.setPlaylist(_allSongs);
      _audioService.play();
    }
  }

  void playFavorites() {
    if (_favoriteSongs.isNotEmpty) {
      _audioService.setPlaylist(_favoriteSongs);
      _audioService.play();
    }
  }

  void playPlaylist(String playlistId) {
    final songs = getPlaylistSongs(playlistId);
    if (songs.isNotEmpty) {
      _audioService.setPlaylist(songs);
      _audioService.play();
    }
  }

  void playSong(Song song, {List<Song>? playlist}) {
    final playlistToUse = playlist ?? _allSongs;
    final index = playlistToUse.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _audioService.setPlaylist(playlistToUse, initialIndex: index);
      _audioService.play();
    }
  }
}
