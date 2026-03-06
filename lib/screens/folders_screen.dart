// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';
import 'cards_screen.dart';
import 'delete_confirmation.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepository = FolderRepository();
  final CardRepository _cardRepository = CardRepository();

  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepository.getAllFolders();
    final Map<int, int> counts = {};

    for (final folder in folders) {
      if (folder.id != null) {
        counts[folder.id!] =
            await _cardRepository.getCardCountByFolder(folder.id!);
      }
    }

    if (!mounted) return;
    setState(() {
      _folders = folders;
      _cardCounts = counts;
    });
  }

  Future<void> _deleteFolder(Folder folder) async {
    final folderId = folder.id!;
    final count = _cardCounts[folderId] ?? 0;

    final confirmed = await DeleteConfirmation.show(
      context: context,
      title: 'Delete Folder?',
      message:
          'Deleting "${folder.folderName}" will also delete ALL $count cards inside it.\n\n'
          'This happens because the database uses ON DELETE CASCADE.',
    );

    if (confirmed) {
      await _folderRepository.deleteFolder(folderId);
      await _loadFolders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "${folder.folderName}" deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.05,
        ),
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          final cardCount = _cardCounts[folder.id!] ?? 0;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardsScreen(folder: folder),
                  ),
                );
                _loadFolders();
              },

              // FIXED UI
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getSuitSymbol(folder.folderName),
                          style: TextStyle(
                            fontSize: 60,
                            color: _getSuitColor(folder.folderName),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          folder.folderName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$cardCount cards',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFolder(folder),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ REAL SUIT SYMBOLS
  String _getSuitSymbol(String suitName) {
    switch (suitName) {
      case 'Hearts':
        return '♥';
      case 'Diamonds':
        return '♦';
      case 'Clubs':
        return '♣';
      case 'Spades':
        return '♠';
      default:
        return '?';
    }
  }

  Color _getSuitColor(String suitName) {
    switch (suitName) {
      case 'Hearts':
      case 'Diamonds':
        return Colors.red;
      case 'Clubs':
      case 'Spades':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}