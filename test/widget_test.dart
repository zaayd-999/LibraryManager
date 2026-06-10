import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:application1/main.dart';

void main() {
  testWidgets('Add book functionality test', (WidgetTester tester) async {
    // Increase surface size for the dialog to fit
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const LibraryApp());

    // Tap the FAB to open the dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill the form
    await tester.enterText(find.widgetWithText(TextField, 'Book title'), 'New Test Book');
    await tester.enterText(find.widgetWithText(TextField, 'Author name'), 'Test Author');
    
    // Tap "Add Book" button
    await tester.tap(find.text('Add Book'));
    await tester.pumpAndSettle();

    // Verify the book is added
    expect(find.text('5 books'), findsOneWidget);
    expect(find.text('New Test Book'), findsOneWidget);
  });

  testWidgets('Favorite toggle test', (WidgetTester tester) async {
    await tester.pumpWidget(const LibraryApp());

    // Find the first book's favorite_border icon
    final favoriteIconFinder = find.byIcon(Icons.favorite_border).first;
    expect(favoriteIconFinder, findsOneWidget);

    // Tap the favorite icon
    await tester.tap(favoriteIconFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 300)); // Complete animation
    await tester.pumpAndSettle();

    // Verify it changed to Icons.favorite
    // Initial 1 + 1 new = 2
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));
  });
}
