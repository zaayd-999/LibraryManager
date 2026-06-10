class BorrowEntry {
  final int bookReservationId;
  final int bookId;
  final String bookTitle;
  final String status;
  final String reservedAt;
  final int durationDays;
  final String dueDate;
  final String? returnedAt;

  const BorrowEntry({
    required this.bookReservationId,
    required this.bookId,
    required this.bookTitle,
    required this.status,
    required this.reservedAt,
    required this.durationDays,
    required this.dueDate,
    this.returnedAt,
  });

  bool get isReturned => returnedAt != null;

  factory BorrowEntry.fromJson(Map<String, dynamic> json) {
    return BorrowEntry(
      bookReservationId: json['BookReservationId'],
      bookId: json['BookId'],
      bookTitle: json['BookTitle'],
      status: json['Status'],
      reservedAt: json['ReservedAt'],
      durationDays: json['DurationDays'],
      dueDate: json['DueDate'],
      returnedAt: json['ReturnedAt'],
    );
  }
}