import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_generator_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instant Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => _initialized
              ? (_error != null
                    ? Scaffold(body: Center(child: Text(_error!)))
                    : const HomeScreen())
              : const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
          '/qr_generator': (context) => const QrGeneratorScreen(),
          '/qr_scanner': (context) => const QrScannerScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final chatId = settings.arguments as String?;
            if (chatId != null) {
              return MaterialPageRoute(
                builder: (context) => ChatScreen(chatId: chatId),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
