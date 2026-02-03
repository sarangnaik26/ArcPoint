import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/isar_service.dart';
import 'providers/theme_provider.dart';
import 'providers/novel_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NovelProvider(isarService)),
      ],
      child: const ArcPointApp(),
    ),
  );
}

class ArcPointApp extends StatelessWidget {
  const ArcPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'ArcPoint',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
    );
  }
}
