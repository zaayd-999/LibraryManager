import 'package:flutter/material.dart';
import '../../models/borrow_entry.dart';
import '../../services/borrow_api.dart';
import 'widgets/borrowed_book_card.dart';

class CurrentBorrowedTab extends StatefulWidget {
  const CurrentBorrowedTab({super.key});

  @override
  State<CurrentBorrowedTab> createState() => _CurrentBorrowedTabState();
}

class _CurrentBorrowedTabState extends State<CurrentBorrowedTab> {
  late Future<List<BorrowEntry>> _borrowedFuture;

  @override
  void initState() {
    super.initState();
    _borrowedFuture = BorrowApi.getBorrows();
  }

  Future<void> _refreshBorrows() async {
    setState(() {
      _borrowedFuture = BorrowApi.getBorrows();
    });
  }

  Future<void> _returnBook(BorrowEntry entry) async {
    try {
      await BorrowApi.returnBook(entry.bookReservationId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book returned successfully')),
      );

      _refreshBorrows();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BorrowEntry>>(
      future: _borrowedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final borrowedBooks = snapshot.data ?? [];

        if (borrowedBooks.isEmpty) {
          return const Center(child: Text('No books borrowed'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: borrowedBooks.length,
          itemBuilder: (context, index) {
            return BorrowedBookCard(
              entry: borrowedBooks[index],
              onReturn: () => _returnBook(borrowedBooks[index]),
            );
          },
        );
      },
    );
  }
}