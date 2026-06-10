import 'package:flutter/material.dart';
import '../../models/borrow_entry.dart';
import '../../services/borrow_api.dart';
import 'widgets/history_book_card.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BorrowEntry>>(
      future: BorrowApi.getBorrowsHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final historyBooks = snapshot.data ?? [];

        if (historyBooks.isEmpty) {
          return const Center(child: Text('No history yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyBooks.length,
          itemBuilder: (context, index) {
            return HistoryBookCard(
              entry: historyBooks[index],
            );
          },
        );
      },
    );
  }
}