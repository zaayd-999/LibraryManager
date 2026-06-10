import 'package:flutter/material.dart';
import '../../../models/borrow_entry.dart';
import '../../../utils/app_colors.dart';

class BorrowedBookCard extends StatelessWidget {
  final BorrowEntry entry;
  final VoidCallback onReturn;

  const BorrowedBookCard({
    super.key,
    required this.entry,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 80,
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
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BorrowedBookInfo(entry: entry),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Extend Date'),
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: AppColors.border,
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onReturn,
                  icon: const Icon(
                    Icons.assignment_return,
                    size: 16,
                  ),
                  label: const Text('Return Book'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BorrowedBookInfo extends StatelessWidget {
  final BorrowEntry entry;

  const _BorrowedBookInfo({
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
        const SizedBox(height: 8),
        Text(
          'Borrowed ${entry.reservedAt}',
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Due ${entry.dueDate}',
          style: const TextStyle(
            color: AppColors.orange,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.5,
            minHeight: 6,
            color: AppColors.orange,
            backgroundColor: AppColors.border,
          ),
        ),
      ],
    );
  }
}