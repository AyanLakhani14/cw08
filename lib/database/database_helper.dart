import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
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
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
        ON DELETE CASCADE
      )
    ''');

    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

  Future _prepopulateFolders(Database db) async {
    final folders = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

    for (var folder in folders) {
      await db.insert('folders', {
        'folder_name': folder,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    final cards = [
      'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'
    ];

    // Suit -> DeckOfCards suit letter
    String suitToLetter(String suit) {
      switch (suit) {
        case 'Spades':
          return 'S';
        case 'Hearts':
          return 'H';
        case 'Diamonds':
          return 'D';
        case 'Clubs':
          return 'C';
        default:
          return 'S';
      }
    }

    // Card name -> DeckOfCards value code
    String cardToValue(String cardName) {
      switch (cardName) {
        case 'Ace':
          return 'A';
        case 'Jack':
          return 'J';
        case 'Queen':
          return 'Q';
        case 'King':
          return 'K';
        case '10':
          return '0'; // DeckOfCards uses 0 for 10
        default:
          return cardName; // '2'..'9'
      }
    }

    for (int folderId = 1; folderId <= suits.length; folderId++) {
      final suitName = suits[folderId - 1];
      final suitLetter = suitToLetter(suitName);

      for (var card in cards) {
        final value = cardToValue(card);
        final imageUrl = 'https://deckofcardsapi.com/static/img/$value$suitLetter.png';

        await db.insert('cards', {
          'card_name': card,
          'suit': suitName,
          'image_url': imageUrl, // ✅ now network URL, no downloading images
          'folder_id': folderId,
        });
      }
    }
  }
}