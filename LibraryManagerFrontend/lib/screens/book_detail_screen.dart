import 'package:flutter/material.dart';

import '../models/book.dart';
import '../repositories/book_repository.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookRepository repository = BookRepository();
  bool _isWishlisted = false;
  Future<Book?>? _bookFuture;

  @override
  void initState() {
    super.initState();
    _bookFuture = repository.getBookById(widget.bookId);
  }

  void _toggleWishlist() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });
  }

  void _deleteBook() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book"),
        content: const Text("Are you sure you want to delete this book?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      
      final success = await repository.deleteBook(widget.bookId);
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Book deleted successfully")),
        );
        navigator.pop(true); // Go back after deletion
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Failed to delete book")),
        );
      }
    }
  }

  void _modifyBook() async {
    final book = await _bookFuture;
    if (book == null) return;

    final titleController = TextEditingController(text: book.title);
    final descriptionController = TextEditingController(text: book.description);
    final yearController = TextEditingController(text: book.publicationYear.toString());
    final isbnController = TextEditingController(text: book.isbn);
    final copiesController = TextEditingController(text: book.totalCopies.toString());
    final shelfController = TextEditingController(text: book.shelfLocation);
    final languageController = TextEditingController(text: book.language);

    bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modify Book"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
              TextField(controller: yearController, decoration: const InputDecoration(labelText: "Year"), keyboardType: TextInputType.number),
              TextField(controller: isbnController, decoration: const InputDecoration(labelText: "ISBN")),
              TextField(controller: copiesController, decoration: const InputDecoration(labelText: "Total Copies"), keyboardType: TextInputType.number),
              TextField(controller: shelfController, decoration: const InputDecoration(labelText: "Shelf")),
              TextField(controller: languageController, decoration: const InputDecoration(labelText: "Language")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              
              final success = await repository.updateBook({
                'BookId': widget.bookId,
                'BookTitle': titleController.text,
                'BookDescription': descriptionController.text,
                'BookPublicationYear': int.tryParse(yearController.text) ?? book.publicationYear,
                'BookIsbn': isbnController.text,
                'BookTotalCopies': int.tryParse(copiesController.text) ?? book.totalCopies,
                'BookShelf': shelfController.text,
                'BookLanguage': languageController.text,
              });
              
              navigator.pop(success);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (updated == true) {
      setState(() {
        _bookFuture = repository.getBookById(widget.bookId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Book updated successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Book?>(
      future: _bookFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Book not found")),
          );
        }

        final book = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F6F2),
          appBar: AppBar(
            title: const Text("Book Details"),
            backgroundColor: const Color(0xFFF8F6F2),
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteBook();
                  } else if (value == 'modify') {
                    _modifyBook();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'modify',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 10),
                        Text("Modify"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Delete"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 180,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "by ${book.author}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (book.genres.isNotEmpty)
                          Wrap(
                            spacing: 10,
                            children: book.genres
                                .map((genre) => Chip(label: Text(genre)))
                                .toList(),
                          ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 5),
                            Text(
                              "${book.rating} (${book.reviewsCount} reviews)",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About this book",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(book.description),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "🟢 Available",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${book.availableCopies} / ${book.totalCopies} copies",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Borrow book clicked");
                    },
                    child: const Text("Borrow Book"),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: _toggleWishlist,
                    icon: Icon(
                      _isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: _isWishlisted ? Colors.red : null,
                    ),
                    label: Text(
                      _isWishlisted ? "In Wishlist" : "Add to Wishlist",
                      style: TextStyle(
                        color: _isWishlisted ? Colors.red : null,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isWishlisted ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Book Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Publisher"),
                            Text(book.publisher),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Publication Year"),
                            Text(book.publicationYear.toString()),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("ISBN"),
                            Text(book.isbn),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Language"),
                            Text(book.language),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Shelf Location"),
                            Text(book.shelfLocation),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}