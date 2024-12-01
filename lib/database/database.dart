import 'dart:io';
import 'package:listadetarefas/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'Titulo';
  String colDate = 'Data';
  String colPriority = 'Prioridade';
  String colStatus = 'status';

 
  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

 
  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}lista_Tarefas.db';
    final tasksDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
      onUpgrade: _onUpgradeDb, 
    );
    return tasksDatabase;
  }


  void _createDb(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE $noteTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTitle TEXT,
        $colDate TEXT,
        $colPriority TEXT,
        $colStatus INTEGER
      )
    ''');
  }

  
  void _onUpgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      
    }
  }

  
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database? db = await this.db;
    try {
      final List<Map<String, dynamic>> result = await db.query(noteTable);
      return result;
    } catch (e) {
      print("Erro ao obter notas: $e");
      return [];
    }
  }

 
  Future<List<Note>> getNoteList() async {
    final List<Map<String, dynamic>> noteMapList = await getNoteMapList();
    final List<Note> noteList = [];

    for (var noteMap in noteMapList) {
      noteList.add(Note.fromMap(noteMap));
    }

    
    noteList.sort((noteA, noteB) => noteA.data!.compareTo(noteB.data!));
    return noteList;
  }


  Future<int> insertNote(Note note) async {
    Database? db = await this.db;
    try {
      final int result = await db.insert(noteTable, note.toMap());
      return result;
    } catch (e) {
      print("Erro ao inserir nota: $e");
      return -1; 
    }
  }

  
  Future<int> updateNote(Note note) async {
    Database? db = await this.db;
    try {
      final int result = await db.update(
        noteTable,
        note.toMap(),
        where: '$colId = ?',
        whereArgs: [note.id],
      );
      return result;
    } catch (e) {
      print("Erro ao atualizar nota: $e");
      return -1; 
    }
  }

  
  Future<int> deleteNote(int id) async {
    Database? db = await this.db;
    try {
      final int result = await db.delete(
        noteTable,
        where: '$colId = ?',
        whereArgs: [id],
      );
      return result;
    } catch (e) {
      print("Erro ao deletar nota: $e");
      return -1; 
    }
  }

  
  Future<void> closeDb() async {
    Database? db = await this.db;
    await db.close();
  }
}
