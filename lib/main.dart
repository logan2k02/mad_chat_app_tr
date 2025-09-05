import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/qr_generator_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/in_app_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AuthService _authService = AuthService();
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _signIn();
  }

  Future<void> _signIn() async {
    try {
      await _authService.signInAnonymously();
      setState(() {
        _initialized = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected successfully!')),
        );
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to connect: $e';
        _initialized = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_error ?? 'Unknown error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: _authService),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => InAppNotificationService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instant Chat',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF222D36),
          primaryColor: const Color(0xFF2AABEE),
          colorScheme: ColorScheme.dark(
            primary: Color(0xFF2AABEE),
            secondary: Color(0xFF222D36),
            background: Color(0xFF222D36),
            surface: Color(0xFF232D36),
            onPrimary: Colors.white,
            onSecondary: Colors.white70,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF232D36),
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
            bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
            bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF232D36),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: Colors.white38),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => _initialized
              ? (_error != null
                    ? Scaffold(body: Center(child: Text(_error!)))
                    : const LoginScreen())
              : const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
          '/home': (context) {
            final authService = Provider.of<AuthService>(
              context,
              listen: false,
            );
            if (authService.isEmailVerified) {
              return const HomeScreen();
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Email Verification Required'),
                ),
                body: const Center(
                  child: Text('Please verify your email to access the app.'),
                ),
              );
            }
          },
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/qr_generator': (context) => const QrGeneratorScreen(),
          '/qr_scanner': (context) => const QrScannerScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final chatId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                if (!authService.isEmailVerified) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Email Verification Required'),
                    ),
                    body: const Center(
                      child: Text('Please verify your email to access chat.'),
                    ),
                  );
                }
                if (chatId != null) {
                  return ChatScreen(chatId: chatId);
                }
                return const Scaffold(
                  body: Center(child: Text('Invalid chat ID.')),
                );
              },
            );
          }
          return null;
        },
      ),
    );
  }
}
