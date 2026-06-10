import '../models/book.dart';
import '../services/database_service.dart';

class BookRepository {
  Future<List<Book>> getBooks() async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery(
      'SELECT * FROM Book',
    );

    return result.map((row) => Book.fromMap(row)).toList();
  }

  Future<Book?> getBookById(int id) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery(
      'SELECT * FROM Book WHERE BookId = ?',
      [id],
    );

    if (result.isEmpty) return null;

    return Book.fromMap(result.first);
  }
}