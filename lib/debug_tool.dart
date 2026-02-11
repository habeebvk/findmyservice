import 'package:flutter/foundation.dart';
import 'services/database_service.dart';
import 'package:sqflite/sqflite.dart';

Future<void> dumpAllReviewsVerbose() async {
  final dbService = DatabaseService();
  final roles = [
    'main',
    'plumber',
    'electrician',
    'taxi',
    'carpenter',
    'mechanic',
    'cleaner',
    'painter',
    'welder',
    'pest_care',
    'glass_repair',
    'gardening',
  ];

  debugPrint("🚀 COMPREHENSIVE REVIEW DUMP");

  for (String role in roles) {
    try {
      final db = await dbService.getDatabase(role);
      final List<Map<String, dynamic>> maps = await db.query('reviews');
      debugPrint("📦 Role DB: $role (${maps.length} reviews found)");
      for (var map in maps) {
        debugPrint(
          "   📍 ID: ${map['id']} | Worker: '${map['workerName']}' | Customer: '${map['customerName']}' | Comment: '${map['comment']}'",
        );
        if (map.containsKey('role')) {
          debugPrint("      Stored Role: ${map['role']}");
        }
      }
    } catch (e) {
      if (!e.toString().contains('no such table')) {
        debugPrint("⚠️ Error reading $role: $e");
      }
    }
  }
}

Future<void> listUsersVerbose() async {
  final dbService = DatabaseService();
  try {
    final db = await dbService.getDatabase('main');
    final List<Map<String, dynamic>> maps = await db.query('users');
    debugPrint("👤 USER DATABASE DUMP (${maps.length} users found)");
    for (var map in maps) {
      debugPrint(
        "   👤 Name: '${map['name']}' | Email: '${map['email']}' | Role: '${map['role']}' | WorkType: '${map['workType']}'",
      );
    }
  } catch (e) {
    debugPrint("⚠️ Error listing users: $e");
  }
}
