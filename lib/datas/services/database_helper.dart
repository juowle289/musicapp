import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:musicapp/datas/models/song.dart';
import 'package:musicapp/datas/models/playlist.dart';
import 'package:musicapp/datas/models/comment.dart';

class DatabaseHelper {
  static Database? _database;
  static const String songsTable = 'songs';
  static const String playlistsTable = 'playlists';
  static const String lovedSongsTable = 'loved_songs';
  static const String commentsTable = 'comments';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'music_app.db');
    return await openDatabase(
      path, 
      version: 7, 
      onCreate: _createDB, 
      onUpgrade: _onUpgrade
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE $songsTable ADD COLUMN creatorEmail TEXT');
      } catch (e) {}
      
      try {
        await db.execute('ALTER TABLE playlists ADD COLUMN creatorEmail TEXT');
      } catch (e) {}
    }

    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE $lovedSongsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            songId TEXT NOT NULL,
            userEmail TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            UNIQUE(songId, userEmail)
          )
        ''');
      } catch (e) {}
    }

    if (oldVersion < 5) {
      try {
        await db.execute('''
          CREATE TABLE $commentsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            songId INTEGER NOT NULL,
            authorEmail TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      } catch (e) {}
    }

    // Version 6: Add playCount column to songs table
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE $songsTable ADD COLUMN playCount INTEGER DEFAULT 0');
      } catch (e) {}
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $songsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        duration INTEGER NOT NULL,
        coverPath TEXT,
        audioPath TEXT,
        creatorEmail TEXT,
        playCount INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
    CREATE TABLE playlists (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      coverPath TEXT,
      createdAt TEXT NOT NULL,
      songIds TEXT,
      creatorEmail TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE $lovedSongsTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      songId TEXT NOT NULL,
      userEmail TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      UNIQUE(songId, userEmail)
    )
    ''');

    await db.execute('''
    CREATE TABLE $commentsTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      songId INTEGER NOT NULL,
      authorEmail TEXT NOT NULL,
      content TEXT NOT NULL,
      createdAt TEXT NOT NULL
    )
    ''');
  }

  // Song CRUD operations
  Future<int> insertSong(Song song) async {
    final db = await database;
    return await db.insert(songsTable, song.toMap());
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(songsTable);
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getTopSongs({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      songsTable,
      orderBy: 'playCount DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<void> incrementPlayCount(int songId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $songsTable SET playCount = playCount + 1 WHERE id = ?',
      [songId],
    );
  }

  Future<int> updateSong(Song song) async {
    final db = await database;
    return await db.update(
      songsTable,
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete(songsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<Song?> getSong(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      songsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Song.fromMap(maps.first);
    }
    return null;
  }

  // Playlist CRUD operations
  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist.toMap());
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Playlist.fromMap(maps[i]));
  }

  Future<Playlist?> getPlaylist(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Playlist.fromMap(maps.first);
    return null;
  }

  Future<int> updatePlaylist(Playlist playlist) async {
    final db = await database;
    return await db.update(
      'playlists',
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<int> deletePlaylist(int id) async {
    final db = await database;
    return await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  // Loved songs operations
  Future<List<String>> getLovedSongIds(String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      lovedSongsTable,
      where: 'userEmail = ?',
      whereArgs: [userEmail],
    );
    return maps.map((map) => map['songId'].toString()).toList();
  }

  Future<void> addLovedSong(String songId, String userEmail) async {
    final db = await database;
    await db.insert(
      lovedSongsTable,
      {
        'songId': songId,
        'userEmail': userEmail,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeLovedSong(String songId, String userEmail) async {
    final db = await database;
    await db.delete(
      lovedSongsTable,
      where: 'songId = ? AND userEmail = ?',
      whereArgs: [songId, userEmail],
    );
  }

  Future<bool> isSongLoved(String songId, String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      lovedSongsTable,
      where: 'songId = ? AND userEmail = ?',
      whereArgs: [songId, userEmail],
    );
    return maps.isNotEmpty;
  }

  // Comment operations
  Future<int> insertComment(Comment comment) async {
    final db = await database;
    return await db.insert(commentsTable, comment.toMap());
  }

  Future<List<Comment>> getComments(int songId, {int page = 0, int limit = 10}) async {
    final db = await database;
    final offset = page * limit;
    final List<Map<String, dynamic>> maps = await db.query(
      commentsTable,
      where: 'songId = ?',
      whereArgs: [songId],
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
  }

  Future<int> deleteComment(int id) async {
    final db = await database;
    return await db.delete(commentsTable, where: 'id = ?', whereArgs: [id]);
  }
}
