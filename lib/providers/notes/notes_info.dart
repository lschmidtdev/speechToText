import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_notes_app/utils/strings.dart';

class NotesInfo with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  bool isFavourite;

  NotesInfo({
    this.id = '',
    required this.title,
    required this.description,
    required this.dateTime,
    this.isFavourite = false,
  });

  void _setFavouriteValue (bool newVal) {
    isFavourite = newVal;
    notifyListeners();
  }

  void _setFavValue(bool newVal) {
    isFavourite = newVal;
    notifyListeners();
  }

  Future<void> toggleFavourites({
    required String userId,
    required String authToken,
  }) async {
    bool oldStatus = isFavourite;
    final url = StringsConst.dbUrl0 + "userFavourites/$userId/$id.json?auth=$authToken";
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(isFavourite),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (_) {
      _setFavValue(oldStatus);
    }
    notifyListeners();
  }
}


