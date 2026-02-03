import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
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
                        trailing: marker.externalLink != null
                            ? IconButton(
                                icon: const Icon(Icons.open_in_new, size: 20),
                                onPressed: () {},
                              ) // TODO: Open URL
                            : null,
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
      builder: (context) => _AddMarkerDialog(novel: novel),
    );
  }
}

class _AddMarkerDialog extends StatefulWidget {
  final Novel novel;
  const _AddMarkerDialog({required this.novel});

  @override
  State<_AddMarkerDialog> createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<_AddMarkerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _chapterController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Chapter Marker'),
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
        FilledButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final marker = ChapterMarker()
        ..chapterNumber = int.parse(_chapterController.text)
        ..description = _descController.text
        ..externalLink = _linkController.text.isNotEmpty
            ? _linkController.text
            : null;

      final isar = Isar.getInstance()!;
      await isar.writeTxn(() async {
        await isar.chapterMarkers.put(marker);
        widget.novel.chapterMarkers.add(marker);
        await widget.novel.chapterMarkers.save();
      });
      if (mounted) Navigator.pop(context);
    }
  }
}
