import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/novel.dart';
import '../../models/chapter_marker.dart';

class MarkersTab extends StatelessWidget {
  final Novel novel;

  const MarkersTab({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<ChapterMarker>>(
      stream: novel.chapterMarkers.filter().watch(fireImmediately: true),
      builder: (context, snapshot) {
        final markers = snapshot.data ?? [];
        markers.sort(
          (a, b) => b.chapterNumber.compareTo(a.chapterNumber),
        ); // Sort by chapter desc

        return Scaffold(
          body: markers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withAlpha(
                          128,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No chapter markers added yet. Mark important moments!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: markers.length,
                  itemBuilder: (context, index) {
                    final marker = markers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          child: Text(
                            '${marker.chapterNumber}',
                            style: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(marker.description),
                        subtitle: marker.externalLink != null
                            ? Text(
                                marker.externalLink!,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (marker.externalLink != null)
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 20),
                                onPressed: () =>
                                    _launchUrl(context, marker.externalLink!),
                                tooltip: 'Open Link',
                              ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editMarker(context, marker);
                                } else if (value == 'delete') {
                                  _deleteMarker(context, marker);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addMarker(context),
            child: const Icon(Icons.add_location_alt_rounded),
          ),
        );
      },
    );
  }

  void _addMarker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _MarkerDialog(novel: novel),
    );
  }

  void _editMarker(BuildContext context, ChapterMarker marker) {
    showDialog(
      context: context,
      builder: (context) => _MarkerDialog(novel: novel, marker: marker),
    );
  }

  Future<void> _deleteMarker(BuildContext context, ChapterMarker marker) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Marker'),
        content: const Text('Are you sure you want to delete this marker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final isar = Isar.getInstance()!;
      await isar.writeTxn(() async {
        await isar.chapterMarkers.delete(marker.id);
        novel.chapterMarkers.remove(
          marker,
        ); // Ensure local list update if needed
        await novel.chapterMarkers.save();
      });
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid URL: $urlString'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _MarkerDialog extends StatefulWidget {
  final Novel novel;
  final ChapterMarker? marker;

  const _MarkerDialog({required this.novel, this.marker});

  @override
  State<_MarkerDialog> createState() => _MarkerDialogState();
}

class _MarkerDialogState extends State<_MarkerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _chapterController;
  late TextEditingController _descController;
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _chapterController = TextEditingController(
      text: widget.marker?.chapterNumber.toString() ?? '',
    );
    _descController = TextEditingController(
      text: widget.marker?.description ?? '',
    );
    _linkController = TextEditingController(
      text: widget.marker?.externalLink ?? '',
    );
  }

  @override
  void dispose() {
    _chapterController.dispose();
    _descController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.marker == null ? 'Add Chapter Marker' : 'Edit Chapter Marker',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _chapterController,
              decoration: const InputDecoration(labelText: 'Chapter Number *'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Short Description *',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'External Link (Optional)',
                hintText: 'https://example.com',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.marker == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final isar = Isar.getInstance()!;

      await isar.writeTxn(() async {
        final marker =
            widget.marker ?? ChapterMarker(); // Use existing or create new
        marker
          ..chapterNumber = int.parse(_chapterController.text)
          ..description = _descController.text
          ..externalLink = _linkController.text.isNotEmpty
              ? _linkController.text
              : null;

        if (widget.marker == null) {
          // Verify we aren't creating a duplicate if that matters, but for now just add
          await isar.chapterMarkers.put(marker);
          widget.novel.chapterMarkers.add(marker);
        } else {
          await isar.chapterMarkers.put(marker);
        }
        await widget.novel.chapterMarkers.save();
      });
      if (mounted) Navigator.pop(context);
    }
  }
}
