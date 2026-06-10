import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1/library_system';

  Future<List<Book>> getBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_books'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> booksJson = data['books'];
          return booksJson.map((json) => Book.fromMap(json)).toList();
        }
      }
      throw Exception('Failed to load books');
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  Future<bool> createBook(Map<String, dynamic> bookData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating book: $e');
      return false;
    }
  }

  Future<bool> updateBook(Map<String, dynamic> bookData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating book: $e');
      return false;
    }
  }

  Future<bool> deleteBook(int bookId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'BookId': bookId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting book: $e');
      return false;
    }
  }
}
