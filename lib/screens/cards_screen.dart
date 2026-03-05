import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/folder.dart';
import '../repositories/card_repository.dart';
import 'addedit_screen.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  const CardsScreen({super.key, required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  Widget buildCardImage(PlayingCard card) {
  final image = card.imageUrl;

  // 1. Network image
  if (image != null && image.startsWith('http')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        image,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      ),
    );
  }

  // 2. Local file path (image_picker)
  if (image != null && File(image).existsSync()) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(image),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      ),
    );
  }

  // 3. Fallback
  return _fallbackImage();
}

Widget _fallbackImage() {
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.image_not_supported, color: Colors.grey[700]),
  );
}

  final CardRepository _cardRepository = CardRepository();
  List<PlayingCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _cardRepository.getCardsByFolderId(widget.folder.id!);
    setState(() => _cards = cards);
  }

  Future<void> _deleteCard(PlayingCard card) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Card?"),
        content: Text('Are you sure you want to delete "${card.cardName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cardRepository.deleteCard(card.id!);
      _loadCards();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card "${card.cardName}" deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(widget.folder.folderName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditCardScreen(folder: widget.folder),
            ),
          );
          _loadCards();
        },
        child: Icon(Icons.add),
      ),

      body: _cards.isEmpty
          ? Center(
              child: Text(
                "No cards yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: _buildCardImage(card),
                    title: Text(
                      card.cardName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(card.suit),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditCardScreen(
                                  folder: widget.folder,
                                  card: card,
                                ),
                              ),
                            );
                            _loadCards();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCard(card),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCardImage(PlayingCard card) {
    if (card.imageUrl != null && card.imageUrl!.isNotEmpty) {
      final file = File(card.imageUrl!);

      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image_not_supported, color: Colors.grey[700]),
    );
  }
}
