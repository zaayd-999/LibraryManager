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

  factory Book.fromJson(Map<String,dynamic> json) {
    return Book(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      rating: (json['rating'] ?? 4.0).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}