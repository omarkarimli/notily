// lib/note_model.dart

import 'dart:ui';

class Note {
  String title;
  String noteType;
  String content;
  DateTime editedTime;
  Color color;
  bool isDone;
  String amount;
  String date;

  Note({
    required this.title,
    required this.noteType,
    required this.content,
    required this.editedTime,
    required this.color,
    this.isDone = false,
    required this.amount,
    required this.date,
  });
}
