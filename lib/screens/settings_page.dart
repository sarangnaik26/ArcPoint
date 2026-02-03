import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark themes'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (v) => themeProvider.setThemeMode(
              v ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          const Divider(),
          _SectionHeader(title: 'Accent Color'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppAccentColor.values.map((accent) {
                final isSelected = themeProvider.accentColor == accent;
                return GestureDetector(
                  onTap: () => themeProvider.setAccentColor(accent),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent == AppAccentColor.golden
                          ? const Color(0xFFFFD700)
                          : null, // Special case for golden name
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 3,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      gradient: accent != AppAccentColor.golden
                          ? LinearGradient(
                              colors: [
                                _getAccentBaseColor(accent),
                                _getAccentBaseColor(accent).withAlpha(150),
                              ],
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('ArcPoint'),
            subtitle: const Text('The exact point in a story arc.'),
            trailing: const Text('v1.0.0'),
          ),
          const ListTile(
            title: Text('Data Privacy'),
            subtitle: Text('All data is stored locally on your device.'),
          ),
        ],
      ),
    );
  }

  Color _getAccentBaseColor(AppAccentColor accent) {
    switch (accent) {
      case AppAccentColor.green:
        return Colors.green;
      case AppAccentColor.orange:
        return Colors.deepOrange;
      case AppAccentColor.yellow:
        return Colors.amber;
      case AppAccentColor.blue:
        return Colors.blue;
      case AppAccentColor.purple:
        return Colors.deepPurple;
      case AppAccentColor.red:
        return Colors.red;
      case AppAccentColor.pink:
        return Colors.pink;
      case AppAccentColor.golden:
        return const Color(0xFFFFCC00);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
