import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'bucket_list_screen.dart';
import 'completed_screen.dart';
import 'settings_page.dart';
import 'global_search_screen.dart';
import 'novel_dashboard.dart';
import 'tabs/character_detail_popup.dart';
import '../widgets/add_novel_popup.dart';
import '../widgets/novel_selector_dialog.dart';
import '../providers/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to Home

  final List<Widget> _pages = [
    const BucketListScreen(),
    const HomeScreen(),
    const CompletedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'ArcPoint',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GlobalSearchScreen(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => themeProvider.toggleThemeMode(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionMenu(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              0,
              Icons.bookmarks_outlined,
              Icons.bookmarks,
              'Bucket',
            ),
            _buildNavItem(1, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(
              2,
              Icons.check_circle_outline,
              Icons.check_circle,
              'Completed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _buildActionItem(
              context,
              icon: Icons.book,
              label: 'Add Novel',
              onTap: () {
                Navigator.pop(context);
                _showAddNovelPopup(context);
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.person_add,
              label: 'Add Character',
              onTap: () {
                Navigator.pop(context);
                _showAddCharacterFlow(context);
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.people,
              label: 'View Characters',
              onTap: () {
                Navigator.pop(context);
                _showViewCharactersFlow(context);
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.search,
              label: 'Search',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GlobalSearchScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(100),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _showAddNovelPopup(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddNovelPopup());
  }

  void _showAddCharacterFlow(BuildContext context) async {
    final novel = await showDialog(
      context: context,
      builder: (context) => const NovelSelectorDialog(title: 'Select Novel'),
    );

    if (novel != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => CharacterDetailPopup(novel: novel),
      );
    }
  }

  void _showViewCharactersFlow(BuildContext context) async {
    final novel = await showDialog(
      context: context,
      builder: (context) => const NovelSelectorDialog(title: 'Select Novel'),
    );

    if (novel != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NovelDashboard(novel: novel, initialIndex: 1),
        ),
      );
    }
  }
}
