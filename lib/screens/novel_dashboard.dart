import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/novel.dart';
import '../models/novel_status.dart';
import 'tabs/resume_tab.dart';
import 'tabs/characters_tab.dart';
import 'tabs/markers_tab.dart';
import 'tabs/history_tab.dart';
import '../services/status_change_service.dart';
import '../widgets/add_novel_popup.dart';

class NovelDashboard extends StatefulWidget {
  final Novel novel;
  final int initialIndex;

  const NovelDashboard({super.key, required this.novel, this.initialIndex = 0});

  @override
  State<NovelDashboard> createState() => _NovelDashboardState();
}

class _NovelDashboardState extends State<NovelDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final url = widget.novel.externalLink;
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _editNovel() {
    showDialog(
      context: context,
      builder: (context) => AddNovelPopup(novel: widget.novel),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280, // Increased height for link
              pinned: true,
              stretch: true,
              actions: [
                Center(
                  child: PopupMenuButton<NovelStatus>(
                    initialValue: widget.novel.status,
                    offset: const Offset(0, 40),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.novel.status.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    onSelected: (status) => StatusChangeService.changeStatus(
                      context,
                      widget.novel,
                      status,
                    ),
                    itemBuilder: (context) => NovelStatus.values.map((status) {
                      return PopupMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit Novel Info',
                  onPressed: _editNovel,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.novel.coverPath != null)
                      Image.file(
                        File(widget.novel.coverPath!),
                        fit: BoxFit.cover,
                      )
                    else
                      Container(color: colorScheme.surfaceContainerHighest),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(200),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.novel.author != null)
                            Text(
                              widget.novel.author!,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            widget.novel.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.novel.genreTags != null &&
                              widget.novel.genreTags!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: widget.novel.genreTags!
                                  .split(',')
                                  .where((t) => t.trim().isNotEmpty)
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tag.trim(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (widget.novel.externalLink != null &&
                              widget.novel.externalLink!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _launchUrl,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.link,
                                      color: Colors.blueAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.novel.externalLink!,
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          decoration: TextDecoration.underline,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 48), // Spacer
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: theme.colorScheme.onSecondaryContainer,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'Current', icon: Icon(Icons.bookmark_outline)),
                    Tab(text: 'Characters', icon: Icon(Icons.people_outline)),
                    Tab(text: 'Markers', icon: Icon(Icons.flag_outlined)),
                    Tab(text: 'History', icon: Icon(Icons.history)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ResumeTab(novel: widget.novel),
                  CharactersTab(novel: widget.novel),
                  MarkersTab(novel: widget.novel),
                  HistoryTab(novel: widget.novel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
