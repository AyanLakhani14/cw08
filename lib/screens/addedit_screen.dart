
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/card.dart';
import '../models/folder.dart';
import '../repositories/card_repository.dart';
import '../repositories/folder_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final PlayingCard? card;
  final Folder folder;

  const AddEditCardScreen({
    super.key,
    this.card,
    required this.folder,
  });

  @override
  _AddEditCardScreenState createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepository = CardRepository();
  final FolderRepository _folderRepository = FolderRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageController;

  String? _selectedSuit;
  int? _selectedFolderId;
  String? _imagePath;

  final List<String> suits = ["Hearts", "Diamonds", "Clubs", "Spades"];
  List<Folder> _folders = [];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.card?.cardName ?? "");
    _imageController = TextEditingController(text: widget.card?.imageUrl ?? "");

    _selectedSuit = widget.card?.suit;
    _selectedFolderId = widget.card?.folderId ?? widget.folder.id;
    _imagePath = widget.card?.imageUrl;

    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepository.getAllFolders();
    setState(() => _folders = folders);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
        _imageController.text = picked.path;
      });
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final card = PlayingCard(
      id: widget.card?.id,
      cardName: _nameController.text.trim(),
      suit: _selectedSuit!,
      imageUrl: _imagePath,
      folderId: _selectedFolderId!,
    );

    if (widget.card == null) {
      await _cardRepository.insertCard(card);
    } else {
      await _cardRepository.updateCard(card);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.card != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Card" : "Add Card"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Card Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Card Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter a card name" : null,
              ),
              SizedBox(height: 16),

              // Suit Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSuit,
                items: suits.map((suit) {
                  return DropdownMenuItem(
                    value: suit,
                    child: Text(suit),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSuit = value),
                decoration: InputDecoration(
                  labelText: "Suit",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? "Select a suit" : null,
              ),
              SizedBox(height: 16),

              // Folder Dropdown
              DropdownButtonFormField<int>(
                value: _selectedFolderId,
                items: _folders.map((folder) {
                  return DropdownMenuItem(
                    value: folder.id,
                    child: Text(folder.folderName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedFolderId = value),
                decoration: InputDecoration(
                  labelText: "Folder",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Image Picker + URL Input
              Text(
                "Card Image",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              Row(
                children: [
                ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.photo),
                    label: Text("Pick Image"),
                  ),
                  SizedBox(width: 12),
                  if (_imagePath != null && _imagePath!.isNotEmpty)
                    Text("Selected", style: TextStyle(color: Colors.green)),
                ],
              ),

              SizedBox(height: 12),

              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(
                  labelText: "Image Path or URL",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _imagePath = value,
              ),

              SizedBox(height: 24),

              // Save + Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: _saveCard,
                    child: Text(isEditing ? "Save Changes" : "Add Card"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
