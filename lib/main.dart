// lib/main.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:notily/home_page.dart';
import 'package:notily/intro_page.dart';
import 'package:notily/settings_model.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';

import 'note_model.dart';

import 'package:notily/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final settings = await _MyHomePageState().readSettings(); // Load settings
  runApp(MyApp(settings: settings,));
}

class MyApp extends StatelessWidget {
  final Settings settings;

  const MyApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      themeMode: ThemeMode.light,

      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Colors.transparent, // transparent
          centerTitle: false,

          iconTheme: IconThemeData(
            color: Colors.black, // Set the color of the AppBar's icon
            size: 18, // Set the size of the AppBar's icon
          ),
        ),

        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF201A1A),
            fontSize: 32,
            fontWeight: FontWeight.w500,
            height: 1.22,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF201A1A),
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF201A1A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.50,
            letterSpacing: 0.15,
          ),

          displayLarge: TextStyle(
            color: Color(0xFF201A1A),
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 1.50,
            letterSpacing: 0.15,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF201A1A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.43,
            letterSpacing: 0.25,
          ),
          displaySmall: TextStyle(
            color: Color(0xFF201A1A),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.43,
            letterSpacing: 0.25,
          ),

          bodyMedium: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFFFFFBFF),
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1,
            letterSpacing: 0.10,
          ),
        ),
      ),

      title: 'note',
      debugShowCheckedModeBanner: false,

      home: const MyHomePage(),

      supportedLocales: L10n.all,
      locale: Locale(settings.lang), // Current Language
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Settings currentSettings = Settings(true, 'USD', 'en'); // initial

  static const String fileName = 'settings.json';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<void> saveSettings(Settings settings) async {
    final file = await _getLocalFile();
    final jsonString = json.encode(settings.toJson());
    await file.writeAsString(jsonString);

    Restart.restartApp();
  }

  Future<Settings> readSettings() async {
    try {
      final file = await _getLocalFile();
      if (file.existsSync()) {
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString);
        return Settings(jsonData['firstOpen'], jsonData['cur'], jsonData['lang']);
      } else {
        // Return default settings if the file doesn't exist
        return Settings(true, 'USD', 'en');
      }
    } catch (e) {
      // Return default settings in case of any error
      return Settings(true, 'USD', 'en');
    }
  }

  void _handleSettingsUpdate(bool firstOpen, String newCurrency, String newLanguage) {
    setState(() {
      currentSettings = Settings(firstOpen, newCurrency, newLanguage); // Update settings
      saveSettings(currentSettings);
      // Other necessary operations...
    });
  }

  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadSettings();
    initialization();
  }

  void _loadSettings() async {
    final savedSettings = await readSettings();
    if (savedSettings != null) {
      setState(() {
        currentSettings = savedSettings;
      });
    }
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  void _saveNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes.json');

    List<Map<String, dynamic>> notesMapList = notes.map((note) {
      return {
        'title': note.title,
        'noteType': note.noteType,
        'content': note.content,
        'editedTime': note.editedTime.toIso8601String(),
        'color': note.color.value,
        'isDone': note.isDone,
        'amount': note.amount,
        'date': note.date,
      };
    }).toList();

    String notesJson = jsonEncode(notesMapList);

    await file.writeAsString(notesJson);
  }

  void _loadNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes.json');

    if (!file.existsSync()) {
      return;
    }

    String notesJson = await file.readAsString();
    List<dynamic> notesList = jsonDecode(notesJson);

    setState(() {
      notes = notesList.map((noteMap) {
        return Note(
          title: noteMap['title'],
          noteType: noteMap['noteType'],
          content: noteMap['content'],
          editedTime: DateTime.parse(noteMap['editedTime']),
          color: Color(noteMap['color']),
          isDone: noteMap['isDone'],
          amount: noteMap['amount'],
          date: noteMap['date'],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if(currentSettings.firstOpen == false){
      return HomePage(
        notes: notes,
        onNotesUpdated: (updatedNotes) {
          setState(() {
            notes = updatedNotes;
            _saveNotes();
          });
        },

        currentSettings: currentSettings,
        updateSettings: (bool firstOpen, String newCurrency, String newLanguage) {
          _handleSettingsUpdate(firstOpen, newCurrency, newLanguage);
        },
      );
    } else{
      return IntroPage(
        notes: notes,
        onNotesUpdated: (updatedNotes) {
          setState(() {
            notes = updatedNotes;
            _saveNotes();
          });
        },

        currentSettings: currentSettings,
        updateSettings: (bool firstOpen, String newCurrency, String newLanguage) {
          _handleSettingsUpdate(firstOpen, newCurrency, newLanguage);
        },
      );
    }
  }
}
