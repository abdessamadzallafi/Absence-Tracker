import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'absence_tracker.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE groups(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  filiere TEXT NOT NULL
);
''');

        await db.execute('''
CREATE TABLE students(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  groupId INTEGER NOT NULL,
  massar TEXT NOT NULL,
  firstName TEXT NOT NULL,
  lastName TEXT NOT NULL,
  email TEXT,
  FOREIGN KEY(groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE modules(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  semester TEXT NOT NULL,
  groupId INTEGER NOT NULL,
  FOREIGN KEY(groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE sessions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  moduleId INTEGER NOT NULL,
  date TEXT NOT NULL,
  time TEXT NOT NULL,
  type TEXT NOT NULL,
  FOREIGN KEY(moduleId) REFERENCES modules(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE absences(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sessionId INTEGER NOT NULL,
  studentId INTEGER NOT NULL,
  status TEXT NOT NULL,
  note TEXT,
  UNIQUE(sessionId, studentId),
  FOREIGN KEY(sessionId) REFERENCES sessions(id) ON DELETE CASCADE,
  FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE
);
''');
      },
    );
    return _db!;
  }
}
