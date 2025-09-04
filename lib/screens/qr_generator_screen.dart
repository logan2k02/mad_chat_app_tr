import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/qr_service.dart';

/// Screen to generate a chat QR code and start a chat session
class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String? _chatId;
  bool _loading = false;
  bool _chatSaved = false;
  final FirestoreService _firestoreService = FirestoreService();
  final QrService _qrService = QrService();
  final TextEditingController _titleController = TextEditingController();

  void _generateChatId() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a chat title.')),
      );
      return;
    }
    setState(() {
      _chatId = _firestoreService.generateChatId();
    });
  }

  Future<void> _saveChatSession() async {
    if (_chatId == null) return;
    setState(() {
      _loading = true;
    });
    final success = await _firestoreService.saveChatSession(
      chatId: _chatId!,
      title: _titleController.text.trim(),
    );
    setState(() {
      _loading = false;
      _chatSaved = success;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Chat saved!' : 'Failed to save chat.')),
    );
  }

  void _openChat() {
    if (_chatId != null) {
      Navigator.pushNamed(context, '/chat', arguments: _chatId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Chat QR')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _chatId == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Enter a title for your chat:'),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Chat Title',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _generateChatId,
                    child: const Text('Generate Chat'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 48),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _titleController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chat ID: $_chatId',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text('Scan this QR to join the chat:'),
                  const SizedBox(height: 24),
                  _qrService.generateQrCode(_chatId!),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _openChat,
                        child: const Text('Open Chat'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 48),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _chatSaved ? null : _saveChatSession,
                        child: const Text('Save Chat'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 48),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
