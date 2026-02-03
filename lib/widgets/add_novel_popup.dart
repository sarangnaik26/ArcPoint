import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../models/novel_status.dart';
import '../providers/novel_provider.dart';

class AddNovelPopup extends StatefulWidget {
  final Novel? novel;

  const AddNovelPopup({super.key, this.novel});

  @override
  State<AddNovelPopup> createState() => _AddNovelPopupState();
}

class _AddNovelPopupState extends State<AddNovelPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _authorController;
  late TextEditingController _genreInputController;
  late TextEditingController _linkController;

  final List<String> _genreTags = [];
  NovelStatus _selectedStatus = NovelStatus.bucketList;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.novel?.name);
    _authorController = TextEditingController(text: widget.novel?.author);
    _genreInputController = TextEditingController();
    _linkController = TextEditingController(text: widget.novel?.externalLink);
    _selectedStatus = widget.novel?.status ?? NovelStatus.bucketList;
    _imagePath = widget.novel?.coverPath;

    if (widget.novel?.genreTags != null &&
        widget.novel!.genreTags!.isNotEmpty) {
      _genreTags.addAll(
        widget.novel!.genreTags!.split(',').map((e) => e.trim()),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  void _addGenre() {
    final text = _genreInputController.text.trim();
    if (text.isNotEmpty && !_genreTags.contains(text)) {
      setState(() {
        _genreTags.add(text);
        _genreInputController.clear();
      });
    }
  }

  void _removeGenre(String tag) {
    setState(() {
      _genreTags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEdit = widget.novel != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? 'Edit Novel' : 'Add New Novel',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Cover Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imagePath != null
                        ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                        : Icon(
                            Icons.add_a_photo_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Novel Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Genre Adder
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _genreTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeGenre(tag),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _genreInputController,
                      decoration: const InputDecoration(
                        labelText: 'Add Genre',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addGenre(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _addGenre,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Novel Web Link (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<NovelStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: NovelStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: Text(isEdit ? 'Save Changes' : 'Add Novel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (widget.novel != null) {
        // Edit Mode
        widget.novel!
          ..name = _nameController.text
          ..author = _authorController.text.isNotEmpty
              ? _authorController.text
              : null
          ..genreTags = _genreTags.isNotEmpty ? _genreTags.join(',') : null
          ..coverPath = _imagePath
          ..status = _selectedStatus
          ..externalLink = _linkController.text.isNotEmpty
              ? _linkController.text
              : null
          // Don't update lastUpdated on meta edit unless desired? Maybe yes.
          ..lastUpdated = DateTime.now();

        context.read<NovelProvider>().updateNovel(widget.novel!);
      } else {
        // Add Mode
        final novel = Novel()
          ..name = _nameController.text
          ..author = _authorController.text.isNotEmpty
              ? _authorController.text
              : null
          ..genreTags = _genreTags.isNotEmpty ? _genreTags.join(',') : null
          ..coverPath = _imagePath
          ..status = _selectedStatus
          ..externalLink = _linkController.text.isNotEmpty
              ? _linkController.text
              : null
          ..lastUpdated = DateTime.now();

        context.read<NovelProvider>().addNovel(novel);
      }
      Navigator.pop(context);
    }
  }
}
