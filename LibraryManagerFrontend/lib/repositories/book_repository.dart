import '../models/book.dart';
import '../services/book_service.dart';

class BookRepository {
  final BookService _bookService = BookService();

  Future<List<Book>> getBooks() async {
    return _bookService.getBooks();
  }

  Future<Book?> getBookById(int id) async {
    final books = await _bookService.getBooks();
    try {
      return books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteBook(int id) async {
    return _bookService.deleteBook(id);
  }

  Future<bool> updateBook(Map<String, dynamic> bookData) async {
    return _bookService.updateBook(bookData);
  }
}
