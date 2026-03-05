import '../database/database_helper.dart';
import '../models/card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<PlayingCard>> getAllCards() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cards');
    return maps.map((m) => PlayingCard.fromMap(m)).toList();
  }

  Future<List<PlayingCard>> getCardsByFolderId(int folderId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
    );
    return maps.map((m) => PlayingCard.fromMap(m)).toList();
  }

  // Alias so your UI can call getCardsByFolder(...)
  Future<List<PlayingCard>> getCardsByFolder(int folderId) async {
    return getCardsByFolderId(folderId);
  }

  Future<int> insertCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return db.insert('cards', card.toMap());
  }

  Future<int> updateCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCardCountByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return (res.first['c'] as int?) ?? 0;
  }
}