import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/novel.dart';
import '../../models/character.dart';
import 'package:isar/isar.dart';
import '../../utils/permission_helper.dart';

class CharacterDetailPopup extends StatefulWidget {
  final Novel novel;
  final Character? character;

  const CharacterDetailPopup({super.key, required this.novel, this.character});

  @override
  State<CharacterDetailPopup> createState() => _CharacterDetailPopupState();
}

class _CharacterDetailPopupState extends State<CharacterDetailPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  String? _imagePath;

  // Status Panel Data Structure: List of Groups
  final List<String> _roleOptions = [
    'Male Lead',
    'Female Lead',
    'Villain',
    'Ally',
    'Relative',
    'Mentor',
    'Subordinate',
    'Rival',
    'Other',
  ];
  String? _selectedRole;
  List<Map<String, dynamic>> _groups = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character?.name);
    _descController = TextEditingController(
      text: widget.character?.description,
    );
    _imagePath = widget.character?.imagePath;
    _selectedRole = widget.character?.role;

    if (widget.character?.statusPanelJson != null) {
      _groups = List<Map<String, dynamic>>.from(
        jsonDecode(widget.character!.statusPanelJson!),
      );
    }

    // If it's a new character, start in edit mode
    if (widget.character == null) {
      _isEditing = true;
    }
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionHelper.requestGalleryPermission(
      context,
    );
    if (!hasPermission) return;

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

  void _addGroup() {
    setState(() {
      _groups.add({'name': '', 'fields': []});
    });
  }

  void _addField(int groupIndex, {required bool isPair}) {
    setState(() {
      if (isPair) {
        _groups[groupIndex]['fields'].add({
          'key': '',
          'value': '',
          'isPair': true,
        });
      } else {
        _groups[groupIndex]['fields'].add({'value': '', 'isPair': false});
      }
    });
  }

  void _removeGroup(int index) => setState(() => _groups.removeAt(index));
  void _removeField(int gIndex, int fIndex) =>
      setState(() => _groups[gIndex]['fields'].removeAt(fIndex));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.character == null
                ? 'New Character'
                : (_isEditing ? 'Edit Character' : 'Character Details'),
          ),
          actions: [
            if (_isEditing)
              TextButton(
                onPressed: _save,
                child: const Text(
                  'SAVE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imagePath != null
                            ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                            : const Icon(Icons.add_a_photo_outlined),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            readOnly: !_isEditing,
                            decoration: const InputDecoration(
                              labelText: 'Name *',
                              hintText: 'Character Name',
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _roleOptions.contains(_selectedRole)
                                ? _selectedRole
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              hintText: 'Select Role',
                            ),
                            items: _roleOptions.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: _isEditing
                                ? (val) => setState(() => _selectedRole = val)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  readOnly: !_isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description/bio...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Status Panel Header
                Row(
                  children: [
                    Text(
                      'STATUS PANEL',
                      style: theme.textTheme.titleSmall?.copyWith(
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    if (_isEditing)
                      FilledButton.tonalIcon(
                        onPressed: _addGroup,
                        icon: const Icon(Icons.add_box_rounded, size: 18),
                        label: const Text('Add Group'),
                      ),
                  ],
                ),
                const Divider(),

                // Groups
                ..._groups.asMap().entries.map((groupEntry) {
                  int gIndex = groupEntry.key;
                  var group = groupEntry.value;
                  return _buildGroup(gIndex, group, theme, isDark);
                }),

                if (_groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No status groups. Add one to track level, skills, or any data!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(
    int index,
    Map<String, dynamic> group,
    ThemeData theme,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: group['name'],
                    readOnly: !_isEditing,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Group Name (e.g. Stats)',
                    ),
                    onChanged: (v) => group['name'] = v,
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _removeGroup(index),
                  ),
              ],
            ),
            const Divider(),
            ...group['fields'].asMap().entries.map((fieldEntry) {
              int fIndex = fieldEntry.key;
              var field = fieldEntry.value;
              bool isPair =
                  field['isPair'] == true || field.containsKey('key'); // Compat

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    if (isPair) ...[
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: field['key'],
                          readOnly: !_isEditing,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Attribute',
                          ),
                          onChanged: (v) => field['key'] = v,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(':'),
                      ),
                    ],
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: field['value'],
                        readOnly: !_isEditing,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Value',
                          prefixIcon: !isPair
                              ? const Icon(Icons.circle, size: 8)
                              : null,
                          prefixIconConstraints: !isPair
                              ? const BoxConstraints(minWidth: 16)
                              : null,
                        ),
                        onChanged: (v) => field['value'] = v,
                      ),
                    ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 16),
                        onPressed: () => _removeField(index, fIndex),
                      ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _addField(index, isPair: true),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Pair'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _addField(index, isPair: false),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Value'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final character = widget.character ?? Character();
      character.name = _nameController.text;
      character.role = _selectedRole;
      character.description = _descController.text;
      character.imagePath = _imagePath;
      character.statusPanelJson = jsonEncode(_groups);

      final isar = Isar.getInstance()!;
      await isar.writeTxn(() async {
        await isar.characters.put(character);
        if (widget.character == null) {
          widget.novel.characters.add(character);
          await widget.novel.characters.save();
        }
      });

      if (mounted) Navigator.pop(context);
    }
  }
}
