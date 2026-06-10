import 'package:flutter/material.dart';

// Book Model
class Book {
  String id;
  String title;
  String author;
  String genre;
  bool isAvailable;
  double rating;
  bool isFavorite;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    this.isAvailable = true,
    this.rating = 4.0,
    this.isFavorite = false,
  });
}

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGridView = false; // starts as list view

  final Color _primaryTeal = const Color(0xFF0A7A8A);
  final List<String> _dbGenres = ['All Genres', 'Classic', 'Coming-of-Age', 'Drama', 'Dystopian', 'Fiction', 'Romance', 'Sci-Fi'];

  String _searchQuery = '';
  String _selectedGenreFilter = 'All Genres';
  String _selectedAuthorFilter = 'All Authors';
  String _sortBy = 'Recently Added';

  // Mock data for test only
  List<Book> books = [
    Book(id: '1', title: 'The Catcher in the Rye', author: 'J.D. Salinger', genre: 'Classic', rating: 4.1, isAvailable: true),
    Book(id: '2', title: 'The Alchemist', author: 'Paulo Coelho', genre: 'Fiction', rating: 4.4, isAvailable: true),
    Book(id: '3', title: 'Valley of the Dolls', author: 'Jacqueline Susann', genre: 'Drama', rating: 3.8, isAvailable: false, isFavorite: true),
    Book(id: '4', title: 'Brave New World', author: 'Aldous Huxley', genre: 'Dystopian', rating: 4.3, isAvailable: true),
  ];

  List<Book> _getFilteredAndSortedBooks() {
    List<Book> filtered = books.where((book) {
      final matchesSearch = book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGenre = _selectedGenreFilter == 'All Genres' || book.genre == _selectedGenreFilter;
      final matchesAuthor = _selectedAuthorFilter == 'All Authors' || book.author == _selectedAuthorFilter;
      return matchesSearch && matchesGenre && matchesAuthor;
    }).toList();

    if (_sortBy == 'Most Popular') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'From A to Z') {
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    // 'Recently Added' is the default list order

    return filtered;
  }

  List<String> _getAuthors() {
    final authors = books.map((b) => b.author).toSet().toList();
    authors.sort();
    return ['All Authors', ...authors];
  }

  // Add Book Dialog
  void _showAddBookDialog() {
    String selectedGenre = _dbGenres.first;
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final descriptionController = TextEditingController();
    final publisherController = TextEditingController();
    final yearController = TextEditingController();
    final isbnController = TextEditingController();
    final copiesController = TextEditingController();
    final shelfController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24), // Spacer for centering
                        const Text('Add New Book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Title *', 'Book title', controller: titleController),
                    _buildTextField('Author *', 'Author name', controller: authorController),

                    // Dropdown for Genres
                    const Text('Genre *', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGenre,
                            isExpanded: true,
                            items: _dbGenres.map((String genre) {
                              return DropdownMenuItem<String>(value: genre, child: Text(genre));
                            }).toList(),
                            onChanged: (String? newValue) {
                              setStateDialog(() => selectedGenre = newValue!);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildTextField('Description', 'Book synopsis...', maxLines: 3, controller: descriptionController),

                    Row(
                      children: [
                        Expanded(child: _buildTextField('Publisher', 'Publisher', controller: publisherController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Year', '2024', controller: yearController)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('ISBN', '978-...', controller: isbnController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Copies', '1', controller: copiesController)),
                      ],
                    ),
                    _buildTextField('Shelf', 'A-01', controller: shelfController), 

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton(
                              onPressed: () {
                                if (titleController.text.isNotEmpty && authorController.text.isNotEmpty) {
                                  setState(() {
                                    books.add(Book(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      title: titleController.text,
                                      author: authorController.text,
                                      genre: selectedGenre == 'All Genres' ? 'Fiction' : selectedGenre,
                                      rating: 4.0,
                                      isAvailable: true,
                                    ));
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryTeal,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Add Book', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // UI Layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FloatingActionButton(
          onPressed: _showAddBookDialog,
          backgroundColor: _primaryTeal,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: _primaryTeal, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LibraryMate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          Text('Discover & Borrow Books', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by title, author...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dropdown Filters
                  Row(
                    children: [
                      Expanded(
                        child: _buildInteractiveFilterDropdown(
                          value: _selectedGenreFilter,
                          items: _dbGenres,
                          onChanged: (value) {
                            setState(() {
                              _selectedGenreFilter = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInteractiveFilterDropdown(
                          value: _selectedAuthorFilter,
                          items: _getAuthors(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAuthorFilter = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body Section
            Expanded(
              child: Container(
                color: const Color(0xFFF5F7F9),
                child: Column(
                  children: [
                    // View Toggles & Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.tune, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
                                items: ['Recently Added', 'Most Popular', 'From A to Z'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _sortBy = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text('${_getFilteredAndSortedBooks().length} books', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 8),
                          _buildViewToggle(Icons.grid_view_rounded, true),
                          const SizedBox(width: 4),
                          _buildViewToggle(Icons.view_list_rounded, false),
                        ],
                      ),
                    ),

                    // Catalog Area
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: _isGridView 
                            ? _buildGridView(_getFilteredAndSortedBooks()) 
                            : _buildListView(_getFilteredAndSortedBooks()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isGrid) {
    bool isActive = _isGridView == isGrid;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _isGridView = isGrid),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? _primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 20, color: isActive ? Colors.white : Colors.grey),
        ),
      ),
    );
  }

  // --- Views ---

  Widget _buildListView(List<Book> displayBooks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: displayBooks.length,
      itemBuilder: (context, index) {
        final book = displayBooks[index];
        return AnimatedBookFrame(
          isFavorite: book.isFavorite,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Najib's job: Navigator.push to book details !!!
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Shared Placeholder Image
                      Container(
                        height: 100,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                _buildFavoriteIcon(book),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(book.author, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusPill(book.isAvailable),
                                _buildRating(book.rating),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Book> displayBooks) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6, // Adjusted for image + content
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: displayBooks.length,
      itemBuilder: (context, index) {
        final book = displayBooks[index];
        return AnimatedBookFrame(
          isFavorite: book.isFavorite,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // najib's job: Navigator.push to book details
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Area (Shared Cover)
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _buildFavoriteIcon(book),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(book.author, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 10),
                          _buildStatusPill(book.isAvailable),
                          const SizedBox(height: 10),
                          _buildRating(book.rating),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteIcon(Book book) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            book.isFavorite = !book.isFavorite;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            book.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: book.isFavorite ? Colors.red : Colors.grey[300],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: isAvailable ? Colors.green : Colors.red),
          const SizedBox(width: 4),
          Text(
            isAvailable ? 'Available' : 'Unavailable',
            style: TextStyle(color: isAvailable ? Colors.green[700] : Colors.red[700], fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(double rating) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) => const Icon(Icons.star, size: 14, color: Colors.amber)),
        ),
        const SizedBox(width: 4),
        Text(rating.toString(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class AnimatedBookFrame extends StatefulWidget {
  final Widget child;
  final bool isFavorite;

  const AnimatedBookFrame({super.key, required this.child, required this.isFavorite});

  @override
  State<AnimatedBookFrame> createState() => _AnimatedBookFrameState();
}

class _AnimatedBookFrameState extends State<AnimatedBookFrame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedBookFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

