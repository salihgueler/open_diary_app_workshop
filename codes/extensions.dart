import 'package:flutter/material.dart';
import 'package:open_diary_app/models/Entry.dart';
import 'package:open_diary_app/models/EntryMood.dart';

extension EntryExtensions on Entry {
  IconData toIconData() {
    switch (mood) {
      case EntryMood.veryBad:
        return Icons.sentiment_very_dissatisfied;
      case EntryMood.bad:
        return Icons.sentiment_dissatisfied;
      case EntryMood.okay:
        return Icons.sentiment_neutral;
      case EntryMood.good:
        return Icons.sentiment_satisfied;
      case EntryMood.veryGood:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.not_accessible;
    }
  }
}
