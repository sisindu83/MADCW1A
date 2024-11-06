import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Model/note.dart';

class DB {
  static final DB _instance = DB._();
  static Database? _database;

  DB._();

  factory DB() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }
//Create
  Future<int> createNote(String title, String content) async {
    final db = await database;
    return await db.insert('notes', {'title': title, 'content': content});
  }
//Read
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  //Update
  Future<int> updateNote(int id, String title, String content) async {
    final db = await database;
    return await db.update(
      'notes',
      {'title': title, 'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
//Delete
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

}
