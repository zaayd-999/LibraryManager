import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database?_database;

  static Future<Database> get database async {
    if (_database != null) {
        return _database!;
      }

      final dbPath= await getDatabasesPath();
      final path = join(dbPath, 'library_database.db');
      final exists = await databaseExists(path);

      if (!exists) {
        final data = await rootBundle.load(
          'assets/database/library_database.db',
        );

        final bytes = data.buffer.asUint8List();

        await File(path).writeAsBytes(bytes, flush: true);
      }

      _database = await openDatabase(path);

      return _database!;
    }
  }
