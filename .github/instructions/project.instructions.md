---
applyTo: "**"
---

# 📌 Project Goal

Develop an Instant Messaging Android Application using Flutter and Firebase Firestore. The app must allow two users to connect via QR code pairing and start a real-time chat session.

This project is an academic assignment (IS3115/SCS3212 - Mobile Application Development). The solution must follow the given marking criteria and deliverables.

# 📌 Tech Stack

- Frontend: Flutter (Dart)
- Backend & Realtime Messaging: Firebase Firestore
- Authentication: Firebase Anonymous Auth
- QR Code: qr_flutter for generation, mobile_scanner for scanning
- State Management: Provider
- Supported Android Version: 9 (Pie) or above

# 📌 Required Features

## 1. Core Chat Functionality (60 Marks)

- Chat UI: Build an intuitive chat interface with bubble-style messages.
- Realtime Messaging: Use Firestore chats/{chatId}/messages collection. Messages must update instantly.
- Text Input & Display: Input field at bottom, message list in chronological order.
- Message Persistence: Store and fetch messages from Firestore (no SQLite).

## 2. QR Code Pairing & Connection (30 Marks)

- QR Code Generation: Generate a chatId and display as a QR code.
- QR Code Scanning: Scan QR using device camera and extract chatId.
- Automated Connection: On scanning, join the chat session automatically.

## 3. Versatility & Robustness (10 Marks)

- Notifications: Use SnackBar or Toast for feedback (e.g., connected, error, invalid QR).
- Exception Handling: Handle invalid QR codes, failed network requests, and empty messages gracefully.

## 📌 Firestore Database Structure

```
chats (collection)
    chatId (document)
    createdAt: timestamp
    messages (subcollection)
        messageId (document)
        senderId: string
        text: string
        timestamp: timestamp
```

# 📌 App Screens

## Home Screen

- Options: Start Chat (QR generator) / Join Chat (QR scanner)

## QR Generator Screen

- Generates chatId, saves in Firestore
- Displays QR code

## QR Scanner Screen

- Scans QR → Extracts chatId
- Redirects to chat screen

## Chat Screen

- Real-time chat messages
- Bubble UI
- Input field + send button

## 📌 Non-Functional Requirements

- Code must be clean, modular, and well-documented.
- Follow Flutter coding conventions.
- Use Provider for state management.
- Separate logic into services/ and UI into screens/.

# 📌 Deliverables

- Flutter project source code (GitHub repo or shared folder).
- Installable APK build (flutter build apk).

## PDF Report:

- Overview of project
- Features
- Tech stack
- Contributions of each member
- Demo Video (< 20 minutes).

# 📌 Folder Structure

```
lib/
  main.dart
  services/
    auth_service.dart
    firestore_service.dart
    qr_service.dart
  screens/
    home_screen.dart
    qr_generator_screen.dart
    qr_scanner_screen.dart
    chat_screen.dart
  widgets/
    message_bubble.dart
    message_input.dart
```

# 📌 Agent Instructions

- Generate clean, working Flutter code for each feature.
- Use Firebase best practices (stream-based UI for Firestore updates).
- Always add error handling and user feedback (SnackBar/Toast).
- Keep UI simple, modern, and responsive.
- Follow the folder structure above.
- Write comments in the code for maintainability.
