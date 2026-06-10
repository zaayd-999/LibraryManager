import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/borrow_entry.dart';

class BorrowApi {
  //static const String baseURL = "http://10.0.2.2:3000/api/v1/library_system";
  static const String baseURL = "http://localhost:3000/api/v1/library_system";
  static Future<List<BorrowEntry>> getBorrows() async {
    final response = await http.get(Uri.parse('$baseURL/get_reservations?status=pending'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List data = body['reservations'];
      return data.map((json) => BorrowEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load borrowed books');
    }
  }
  static Future<List<BorrowEntry>> getBorrowsHistory() async {
    final response = await http.get(Uri.parse('$baseURL/get_reservations?status=returned'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List data = body['reservations'];
      return data.map((json) => BorrowEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load borrow history');
    }
  }

  static Future<bool> returnBook(int bookReservationId) async {
    final response = await http.post(Uri.parse('$baseURL/return_book'),
        headers: {
          'Content-Type' : 'application/json'
        },
        body: jsonEncode({
          'BookReservationId' : bookReservationId,
        })
    );
    if(response.statusCode == 200) return true;
    throw Exception('Failed to return book: ${response.body}');
  }
}