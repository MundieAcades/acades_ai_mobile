# Acades AI — Flutter UI

A clean, modern agricultural AI chat assistant app for Malawian farmers.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, gradients, ThemeData
├── models/
│   └── chat_message.dart        # ChatMessage, ChatHistory models
├── screens/
│   ├── home_screen.dart         # Homepage with gradient + quick actions
│   ├── chat_screen.dart         # Chat with SSE streaming simulation
│   ├── farm_records_screen.dart # Farm records list
│   └── weather_screen.dart      # Weather forecast
└── widgets/
    ├── shared_widgets.dart      # AcadesAppBar, ChatInputBar, QuickActionChip
    ├── acades_drawer.dart       # Side navigation drawer
    └── add_file_sheet.dart      # Bottom sheet: Camera/Detection/Files
```

---

## Design Tokens

| Token | Value |
|-------|-------|
| Primary Green | `#5AAB28` |
| Primary Light | `#6ABF40` |
| Primary Surface | `#EBFFCA` |
| Primary Border | `#D4E8C2` |
| Text Primary | `#1A1A1A` |
| Text Secondary | `#666666` |
| Font | Roboto (via google_fonts) |

**Homepage gradient:**
```dart
LinearGradient(
  begin: Alignment(0.50, 0.49),
  end: Alignment(0.50, 1.00),
  colors: [Colors.white, Color(0xFFEBFFCA)],
)
```

---

## Key Features

### 💬 Chat with Streaming Simulation
`ChatScreen` simulates Server-Sent Events (SSE) by streaming AI responses
word-by-word with a 28ms interval. Replace `_mockResponses` with a real
SSE/WebSocket connection to your backend:

```dart
// Replace this block in ChatScreen._sendMessage():
final channel = WebSocketChannel.connect(Uri.parse('wss://your-api/chat'));
channel.sink.add(jsonEncode({'message': text}));
channel.stream.listen((chunk) {
  setState(() => _streamingText += chunk);
});
```

### 📎 Add File Bottom Sheet
`AddFileBottomSheet.show()` provides Camera, Crop Detection, and File picker
entry points. Wire up with:
```dart
// image_picker
final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);

// flutter_image_compress (compress before upload)
final compressed = await FlutterImageCompress.compressWithFile(
  photo!.path,
  quality: 60,
);
```

### 🗄️ Offline Caching (Isar)
Chat history is designed for Isar. Add the `@Collection()` annotation to
`ChatMessage` and open an Isar instance in `main()`:
```dart
final isar = await Isar.open([ChatMessageSchema], directory: dir.path);
```

### 🏗️ State Management (Riverpod)
Wrap `AcadesApp` with `ProviderScope` for Riverpod:
```dart
void main() {
  runApp(const ProviderScope(child: AcadesApp()));
}
```

---

## Setup

```bash
# 1. Get packages
flutter pub get

# 2. Generate Isar schemas (when models are annotated)
dart run build_runner build

# 3. Run
flutter run
```

### Android permissions (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS permissions (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Acades AI needs camera access for crop detection</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Acades AI needs photo library access to upload farm images</string>
```

---

## Screens Overview

| Screen | Description |
|--------|-------------|
| `HomeScreen` | Gradient landing page with quick-action chips and input bar |
| `ChatScreen` | Full chat UI with streaming bubbles, typing indicator, reaction icons |
| `FarmRecordsScreen` | Record cards with status badges (Growing / Planted / Harvested) |
| `WeatherScreen` | Current conditions + 5-day forecast for Lilongwe |
| `AcadesDrawer` | Side nav with New Chat, Search, Farm Records, Weather, Chat History |
| `AddFileBottomSheet` | Camera / Detection / Files + Farm Records / Agri Training |
