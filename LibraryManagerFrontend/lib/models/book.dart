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
  bool isFavorite; // Removed final to allow modification in UI

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
    this.isFavorite = false,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['BookId'] ?? 0,
      title: map['BookTitle'] ?? '',
      author: map['Authors'] ?? 'Unknown author',
      description: map['BookDescription'] ?? '',
      coverUrl: '',
      genres: (map['Categories'] as String?)?.split(', ') ?? [],
      rating: 4.0,
      reviewsCount: 0,
      publisher: map['Publishers'] ?? 'Unknown publisher',
      publicationYear: map['BookPublicationYear'] ?? 0,
      isbn: map['BookIsbn'] ?? '',
      language: map['BookLanguage'] ?? '',
      shelfLocation: map['BookShelf'] ?? '',
      availableCopies: map['BookTotalCopies'] ?? 0,
      totalCopies: map['BookTotalCopies'] ?? 0,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'BookId': id,
      'BookTitle': title,
      'BookIsbn': isbn,
      'BookPublicationYear': publicationYear,
      'BookTotalCopies': totalCopies,
      'BookDescription': description,
      'BookShelf': shelfLocation,
      'BookLanguage': language,
    };
  }
}
