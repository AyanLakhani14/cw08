import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final Folder folder;
  final PlayingCard? existing;

  const AddEditCardScreen({
    super.key,
    required this.folder,
    this.existing,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepository = CardRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageController;
  late String _selectedSuit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.cardName ?? '');
    _imageController = TextEditingController(text: widget.existing?.imageUrl ?? '');
    _selectedSuit = widget.existing?.suit ?? widget.folder.folderName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final card = PlayingCard(
      id: widget.existing?.id,
      cardName: _nameController.text.trim(),
      suit: _selectedSuit,
      imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
      folderId: widget.folder.id, // stays in this folder
    );

    try {
      if (widget.existing == null) {
        await _cardRepository.insertCard(card);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card added')),
          );
        }
      } else {
        await _cardRepository.updateCard(card);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card updated')),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Card' : 'Add Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Card name (Ace, 2, King...)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Card name required';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedSuit,
                decoration: const InputDecoration(
                  labelText: 'Suit',
                  border: OutlineInputBorder(),
                ),
                items: const ['Hearts', 'Diamonds', 'Clubs', 'Spades']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSuit = val);
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image path or URL',
                  hintText: 'assets/cards/...  OR  https://...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEdit ? 'Save Changes' : 'Add Card'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                'Folder: ${widget.folder.folderName}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
