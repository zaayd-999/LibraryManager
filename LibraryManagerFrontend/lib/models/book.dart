class Book {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final List<String> genres;
  final double rating;
  final int reviewsCount;
  final String publisher;
  final int publicationYear;
  final String isbn;
  final String language;
  final String shelfLocation;
  final int availableCopies;
  final int totalCopies;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.genres,
    required this.rating,
    required this.reviewsCount,
    required this.publisher,
    required this.publicationYear,
    required this.isbn,
    required this.language,
    required this.shelfLocation,
    required this.availableCopies,
    required this.totalCopies,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['BookId'],
      title: map['BookTitle'] ?? '',
      author: 'Unknown author',
      description: map['BookDescription'] ?? '',
      coverUrl: '',
      genres: const [],
      rating: 0,
      reviewsCount: 0,
      publisher: 'Unknown publisher',
      publicationYear: map['BookPublicationYear'] ?? 0,
      isbn: map['BookIsbn'] ?? '',
      language: map['BookLanguage'] ?? '',
      shelfLocation: map['BookShelf'] ?? '',
      availableCopies: map['BookTotalCopies'] ?? 0,
      totalCopies: map['BookTotalCopies'] ?? 0,
    );
  }
}