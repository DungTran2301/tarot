import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/tarot_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TarotProvider())],
      child: const TarotApp(),
    ),
  );
}

class TarotApp extends StatelessWidget {
  const TarotApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Comprehensive fallbacks for emojis and special characters on all platforms
    final List<String> fontFallbacks = [
      'Apple Color Emoji', // iOS, macOS
      'Segoe UI Emoji', // Windows
      'Noto Color Emoji', // Linux, Android
      'Android Emoji',
      'EmojiSymbols',
      'Symbola', // Generic fallback
      'sans-serif',
    ];

    final baseTextTheme = GoogleFonts.beVietnamProTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return MaterialApp(
      title: 'Thông điệp từ vũ trụ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0C29),
        primaryColor: const Color(0xFF302B63),
        fontFamilyFallback: fontFallbacks, // Added at theme level
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B00FF),
          secondary: Color(0xFFFFCC00),
        ),
        textTheme: baseTextTheme
            .apply(fontFamilyFallback: fontFallbacks)
            .copyWith(
              bodyLarge: baseTextTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                fontFamilyFallback: fontFallbacks,
              ),
              bodyMedium: baseTextTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontFamilyFallback: fontFallbacks,
              ),
              titleLarge: baseTextTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamilyFallback: fontFallbacks,
              ),
            ),
      ),
      home: const HomeScreen(),
    );
  }
}
