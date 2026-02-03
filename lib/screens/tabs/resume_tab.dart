import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/novel.dart';
import '../../providers/novel_provider.dart';
import 'package:intl/intl.dart';

class ResumeTab extends StatefulWidget {
  final Novel novel;

  const ResumeTab({super.key, required this.novel});

  @override
  State<ResumeTab> createState() => _ResumeTabState();
}

class _ResumeTabState extends State<ResumeTab> {
  late TextEditingController _summaryController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.novel.storySummary);
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Done clicked, save
      _saveSummary();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _updateChapter(int delta) {
    setState(() {
      widget.novel.currentChapter = (widget.novel.currentChapter + delta).clamp(
        0,
        99999,
      );
    });
    context.read<NovelProvider>().updateNovel(widget.novel);
  }

  void _saveSummary() {
    widget.novel.storySummary = _summaryController.text;
    context.read<NovelProvider>().updateNovel(widget.novel);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Summary saved'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // Chapter Section
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withAlpha(51),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorScheme.primary.withAlpha(51)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Current Chapter',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChapterButton(Icons.remove, () => _updateChapter(-1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '${widget.novel.currentChapter}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    _buildChapterButton(Icons.add, () => _updateChapter(1)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // On Hold Note (if active)
        if (widget.novel.lastOnHoldNote != null &&
            widget.novel.lastOnHoldNote!.isNotEmpty) ...[
          Card(
            elevation: 0,
            color: colorScheme.tertiaryContainer.withAlpha(51),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.tertiary.withAlpha(51)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.anchor_rounded,
                        color: colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resume Anchor (On-Hold Note)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.novel.lastOnHoldNote!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Note Section (formerly Context Summary)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Note',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _toggleEdit,
              icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
              tooltip: _isEditing ? 'Done' : 'Edit Note',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          TextField(
            controller: _summaryController,
            maxLines: 8,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Add a note about the story...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: theme.canvasColor,
            ),
          )
        else
          GestureDetector(
            onDoubleTap: _toggleEdit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(128),
                ),
              ),
              child: Text(
                _summaryController.text.isNotEmpty
                    ? _summaryController.text
                    : 'No notes added.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _summaryController.text.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                  fontStyle: _summaryController.text.isEmpty
                      ? FontStyle.italic
                      : null,
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        // Last Updated
        Center(
          child: Text(
            'Last updated: ${DateFormat('MMM dd, yyyy • HH:mm').format(widget.novel.lastUpdated)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildChapterButton(IconData icon, VoidCallback onPressed) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      padding: const EdgeInsets.all(12),
    );
  }
}
