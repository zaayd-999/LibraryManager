import 'package:flutter/material.dart';
import '../../services/borrow_api.dart';
import '../../utils/app_colors.dart';
import 'current_borrowed_tab.dart';
import 'history_tab.dart';

class MyBooksPage extends StatelessWidget {
  const MyBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Books',
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage your borrowed books',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: AppColors.teal,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.teal,
            tabs: [
              Tab(
                child: FutureBuilder(
                  future: BorrowApi.getBorrows(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Currently Borrowed'),
                        const SizedBox(width: 6),
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: AppColors.red,
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Tab(text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CurrentBorrowedTab(),
            HistoryTab(),
          ],
        ),
      ),
    );
  }
}