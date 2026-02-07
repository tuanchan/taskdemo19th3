import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('music_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE songs (
        id $idType,
        title $textType,
        artist TEXT,
        album TEXT,
        filePath $textType,
        duration $intType,
        albumArt TEXT,
        addedDate $textType,
        isFavorite INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id $idType,
        name $textType,
        createdDate $textType,
        songIds TEXT,
        coverArt TEXT
      )
    ''');
  }

  // Song operations
  Future<void> insertSong(Song song) async {
    final db = await database;
    await db.insert(
      'songs',
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final maps = await db.query('songs', orderBy: 'addedDate DESC');
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  Future<List<Song>> getFavoriteSongs() async {
    final db = await database;
    final maps = await db.query(
      'songs',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'addedDate DESC',
    );
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  Future<void> updateSong(Song song) async {
    final db = await database;
    await db.update(
      'songs',
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<void> deleteSong(String id) async {
    final db = await database;
    await db.delete(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleFavorite(String songId) async {
    final db = await database;
    final song = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [songId],
    );
    
    if (song.isNotEmpty) {
      final isFavorite = song.first['isFavorite'] == 1;
      await db.update(
        'songs',
        {'isFavorite': isFavorite ? 0 : 1},
        where: 'id = ?',
        whereArgs: [songId],
      );
    }
  }

  // Playlist operations
  Future<void> insertPlaylist(Playlist playlist) async {
    final db = await database;
    await db.insert(
      'playlists',
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final maps = await db.query('playlists', orderBy: 'createdDate DESC');
    return maps.map((map) => Playlist.fromMap(map)).toList();
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final db = await database;
    await db.update(
      'playlists',
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<void> deletePlaylist(String id) async {
    final db = await database;
    await db.delete(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
