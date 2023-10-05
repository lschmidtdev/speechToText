import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_notes_app/utils/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'notes_info.dart';

class Notes with ChangeNotifier {
  List<NotesInfo> _notes = [];

  List<NotesInfo> get notes {
    return [..._notes];
  }

  List<NotesInfo> get favNotes {
    return _notes.where((note) => note.isFavourite).toList();
  }

  Notes(this._authToken, this._userId, this._notes);
  final String _authToken;
  final String _userId;

  Future<void> fetchNotesInfo() async {
    final url = StringsConst.dbUrl0 + 'notes.json?auth=$_authToken&orderBy="userId"&equalTo="$_userId"';
    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (responseData == null){
        return;
      }

      final favUrl = StringsConst.dbUrl0 + 'userFavourites/$_userId.json?auth=$_authToken';
      final favResponse = await http.get(Uri.parse(favUrl));
      final favStatus = json.decode(favResponse.body);
      final Map<String, dynamic> notesInfo = responseData;
      final List<NotesInfo> loadedNotes = [];

      notesInfo.forEach((noteId, noteData) {
        loadedNotes.insert(
            0,
            NotesInfo(
              id: noteId,
              title: noteData['title'],
              description: noteData['description'],
              dateTime: DateTime.parse(noteData['dateTime']),
              isFavourite: favStatus == null ? false : favStatus[noteId] ?? false,
            ),
        );
      });
      loadedNotes.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _notes = loadedNotes;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  void searchNotes (String title) {
    final List<NotesInfo> loadedNotes = _notes.where((note) => note.title.toLowerCase().contains(
      title.toLowerCase(),
    ))
        .toList();
    _notes = loadedNotes;
    notifyListeners();
  }

  Future<void> saveNote(NotesInfo info) async {
    final url = StringsConst.dbUrl0 + 'notes.json?auth=$_authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'userId': _userId,
          'title': info.title,
          'description': info.description,
          'dateTime': info.dateTime.toIso8601String(),
        },
        ),
      );

      final newNote = NotesInfo(
        id: json.decode(response.body)['name'],
        title: info.title,
        description: info.description,
        dateTime: info.dateTime,
      );
      _notes.insert(0, newNote);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateNote(String id, NotesInfo info) async {
    int currentIndex = _notes.indexWhere((note) => note.id == id);

    if (currentIndex >= 0) {
      final url = StringsConst.dbUrl0 + 'notes/$id.json?auth=$_authToken';

      try {
        await http.patch(
          Uri.parse(url),
          body: json.encode(
            {
              'title': info.title,
              'description': info.description,
              'dateTime': info.dateTime.toIso8601String(),
            },
          ),
        );
        _notes.removeAt(currentIndex);
        _notes.insert(0, info);
        notifyListeners();
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> deleteNote(String id) async {
    final url = StringsConst.dbUrl0 + 'notes/$id.json?auth=$_authToken';
    int currentIndex = _notes.indexWhere((note) => note.id == id);
    final noteToBeDeleted = _notes[currentIndex];
    _notes.removeAt(currentIndex);
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _notes.insert(currentIndex, noteToBeDeleted);
      notifyListeners();
      throw const HttpException(StringsConst.uneableToDeleteNote);
    }
    notifyListeners();
  }
}