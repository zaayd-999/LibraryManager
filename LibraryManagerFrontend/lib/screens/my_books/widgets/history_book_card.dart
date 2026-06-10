import 'package:flutter/material.dart';
import '../../../models/borrow_entry.dart';
import '../../../utils/app_colors.dart';

class HistoryBookCard extends StatelessWidget {
  final BorrowEntry entry;

  const HistoryBookCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/book_image.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.tealLight,
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.teal,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HistoryBookInfo(entry: entry),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Returned',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryBookInfo extends StatelessWidget {
  final BorrowEntry entry;

  const _HistoryBookInfo({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.bookTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Borrowed: ${entry.reservedAt}',
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Returned: ${entry.returnedAt ?? "-"}',
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Duration: ${entry.durationDays} days',
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}