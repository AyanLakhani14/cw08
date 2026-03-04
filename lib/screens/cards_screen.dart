import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart';
import 'delete_confirmation.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepository = CardRepository();
  List<PlayingCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _cardRepository.getCardsByFolder(widget.folder.id!);
    if (!mounted) return;
    setState(() => _cards = cards);
  }

  Widget _cardImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    return Image.network(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }

  Future<void> _deleteCard(PlayingCard card) async {
    final confirmed = await DeleteConfirmation.show(
      context: context,
      title: 'Delete Card?',
      message: 'Delete "${card.cardName}" from ${widget.folder.folderName}?',
    );

    if (confirmed) {
      await _cardRepository.deleteCard(card.id!);
      await _loadCards();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted')),
        );
      }
    }
  }

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCardScreen(folder: widget.folder),
      ),
    );
    _loadCards();
  }

  Future<void> _openEdit(PlayingCard card) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCardScreen(folder: widget.folder, existing: card),
      ),
    );
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folder.folderName} Cards'),
      ),
      body: _cards.isEmpty
          ? const Center(child: Text('No cards found.'))
          : ListView.separated(
              itemCount: _cards.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = _cards[index];

                return ListTile(
                  leading: _cardImage(c.imageUrl),
                  title: Text(c.cardName),
                  subtitle: Text(c.suit),
                  onTap: () => _openEdit(c),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openEdit(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCard(c),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}