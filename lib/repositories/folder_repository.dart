import '../database/database_helper.dart';
import '../models/folder.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      orderBy: 'folder_name ASC',
    );
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  Future<int> insertFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return db.insert('folders', folder.toMap());
  }

  Future<int> updateFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}