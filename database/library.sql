CREATE TABLE IF NOT EXISTS "Collection" (
    "CollectionId"   INTEGER NOT NULL,
    "CollectionName" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("CollectionId" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "Category" (
    "CategoryId"          INTEGER NOT NULL,
    "CategoryName"        TEXT NOT NULL UNIQUE,
    "CategoryDescription" TEXT,
    PRIMARY KEY("CategoryId" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "Author" (
    "AuthorId"        INTEGER NOT NULL,
    "AuthorFirstName" TEXT NOT NULL,
    "AuthorLastName"  TEXT NOT NULL,
    PRIMARY KEY("AuthorId" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "Publisher" (
    "PublisherId" INTEGER NOT NULL,
    "PublisherFirstName" TEXT NOT NULL,
    "PublisherLastName" TEXT NOT NULL,
    PRIMARY KEY("PublisherId" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "Book" (
    "BookId"              INTEGER NOT NULL,
    "BookTitle"           TEXT NOT NULL,
    "BookIsbn"            TEXT,
    "BookPublicationYear" INTEGER,
    "BookTotalCopies"     INTEGER DEFAULT 0 NOT NULL,
    "BookDescription" TEXT NOT NULL,
    "BookShelf" TEXT NOT NULL,
    "BookLanguage" TEXT NOT NULL,
    PRIMARY KEY("BookId" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "BookCollection" (
    "BookId"           INTEGER NOT NULL,
    "BookCollectionId" INTEGER NOT NULL,
    PRIMARY KEY("BookId", "BookCollectionId"),
    FOREIGN KEY("BookId") REFERENCES "Book"("BookId")
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY("BookCollectionId") REFERENCES "Collection"("CollectionId")
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "BookCategory" (
    "BookId"         INTEGER NOT NULL,
    "BookCategoryId" INTEGER NOT NULL,
    PRIMARY KEY("BookId", "BookCategoryId"),
    FOREIGN KEY("BookId") REFERENCES "Book"("BookId")
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY("BookCategoryId") REFERENCES "Category"("CategoryId")
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "BookAuthor" (
    "BookId"       INTEGER NOT NULL,
    "BookAuthorId" INTEGER NOT NULL,
    PRIMARY KEY("BookId", "BookAuthorId"),
    FOREIGN KEY("BookId") REFERENCES "Book"("BookId")
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY("BookAuthorId") REFERENCES "Author"("AuthorId")
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "BookPublisher" (
    "BookId" INTEGER NOT NULL,
    "BookPublisherId" INTEGER NOT NULL,
    PRIMARY KEY("BookId", "BookPublisherId"),
    FOREIGN KEY("BookId") REFERENCES "Book"("BookId")
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY("BookPublisherId") REFERENCES "Publisher"("PublisherId")
);

CREATE TABLE IF NOT EXISTS "BookReservation" (
    "BookReservationId" INTEGER NOT NULL,
    "BookId"            INTEGER NOT NULL,
    "Status"            TEXT NOT NULL DEFAULT 'pending' CHECK("Status" IN ('pending', 'returned')),
    "ReservedAt"        TEXT NOT NULL DEFAULT (datetime('now')),
    "DurationDays"      INTEGER NOT NULL DEFAULT 14,
    "DueDate"           TEXT GENERATED ALWAYS AS
                        (datetime(ReservedAt, '+' || DurationDays || ' days')) VIRTUAL,
    "ReturnedAt"        TEXT,
    PRIMARY KEY("BookReservationId" AUTOINCREMENT),
    FOREIGN KEY("BookId") REFERENCES "Book"("BookId")
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- Collections
INSERT INTO "Collection" ("CollectionName") VALUES ('Fiction');
INSERT INTO "Collection" ("CollectionName") VALUES ('Non-Fiction');
INSERT INTO "Collection" ("CollectionName") VALUES ('Science');
INSERT INTO "Collection" ("CollectionName") VALUES ('History');
INSERT INTO "Collection" ("CollectionName") VALUES ('Technology');

-- Categories
INSERT INTO "Category" ("CategoryName", "CategoryDescription") VALUES ('Novel', 'A long narrative fictional story');
INSERT INTO "Category" ("CategoryName", "CategoryDescription") VALUES ('Mystery', 'Stories involving a puzzling crime or event');
INSERT INTO "Category" ("CategoryName", "CategoryDescription") VALUES ('Science Fiction', 'Fiction based on imagined future science and technology');
INSERT INTO "Category" ("CategoryName", "CategoryDescription") VALUES ('Biography', 'A written account of a persons life');
INSERT INTO "Category" ("CategoryName", "CategoryDescription") VALUES ('Programming', 'Books about software development and coding');
INSERT INTO "Category" ("CategoryName", "CategoryDescription") VALUES ('History', 'Books about historical events and figures');
INSERT INTO "Category" ("CategoryName", "CategoryDescription") VALUES ('Self-Help', 'Books aimed at self-improvement');

-- Authors
INSERT INTO "Author" ("AuthorFirstName", "AuthorLastName") VALUES ('George', 'Orwell');
INSERT INTO "Author" ("AuthorFirstName", "AuthorLastName") VALUES ('J.K.', 'Rowling');
INSERT INTO "Author" ("AuthorFirstName", "AuthorLastName") VALUES ('Agatha', 'Christie');
INSERT INTO "Author" ("AuthorFirstName", "AuthorLastName") VALUES ('Stephen', 'Hawking');
INSERT INTO "Author" ("AuthorFirstName", "AuthorLastName") VALUES ('Robert', 'Martin');
INSERT INTO "Author" ("AuthorFirstName", "AuthorLastName") VALUES ('Frank', 'Herbert');
INSERT INTO "Author" ("AuthorFirstName", "AuthorLastName") VALUES ('Walter', 'Isaacson');

-- VIEWS

-- BookDetail
DROP VIEW IF EXISTS "main"."BookDetail";
CREATE VIEW BookDetail AS
SELECT 
    Book.*,
    GROUP_CONCAT(DISTINCT Collection.CollectionName) AS Collections,
    GROUP_CONCAT(DISTINCT Category.CategoryName) AS Categories,
    GROUP_CONCAT(DISTINCT Author.AuthorFirstName || ' ' || Author.AuthorLastName) AS Authors,
	group_concat(DISTINCT Publisher.PublisherFirstName || ' ' || Publisher.PublisherLastName) As Publishers
FROM Book
INNER JOIN BookCollection ON Book.BookId = BookCollection.BookId
INNER JOIN Collection     ON Collection.CollectionId = BookCollection.BookCollectionId
INNER JOIN BookCategory   ON Book.BookId = BookCategory.BookId
INNER JOIN Category       ON Category.CategoryId = BookCategory.BookCategoryId
INNER JOIN BookAuthor     ON Book.BookId = BookAuthor.BookId
INNER JOIN Author         ON Author.AuthorId = BookAuthor.BookAuthorId
INNER JOIN BookPublisher  ON Book.BookId = BookPublisher.BookId
INNER JOIN Publisher 	  ON Publisher.PublisherId = BookPublisher.BookPublisherId
GROUP BY Book.BookId

-- ReservationDetail
CREATE VIEW ReservationDetail AS
SELECT 
	BookReservation.BookReservationId,
	Book.BookId,
	Book.BookTitle,
	BookReservation.Status,
	BookReservation.ReservedAt,
	BookReservation.DurationDays,
	BookReservation.DueDate,
	BookReservation.ReturnedAt
FROM Book
INNER JOIN BookReservation ON Book.BookId = BookReservation.BookId;

-- Triggers

CREATE TRIGGER IF NOT EXISTS trg_decrease_copies_after_reserve
AFTER INSERT ON BookReservation
BEGIN
	UPDATE Book
	SET BookTotalCopies = BookTotalCopies - 1
	WHERE BookId = NEW.BookId;
END;

CREATE TRIGGER IF NOT EXISTS trg_increase_copies_after_return
AFTER UPDATE ON BookReservation
WHEN NEW.Status = 'returned' AND OLD.Status = 'pending'
BEGIN
	UPDATE Book
	SET BookTotalCopies = BookTotalCopies + 1
	WHERE BookId = NEW.BookId;
END;

CREATE TRIGGER IF NOT EXISTS trg_set_returned_at
AFTER UPDATE ON BookReservation
WHEN NEW.Status = 'returned' AND OLD.Status = 'pending'
BEGIN
	UPDATE BookReservation
	SET ReturnedAt = datetime('now')
	WHERE BookReservationId = NEW.BookReservationId;
END;

DROP TRIGGER IF EXISTS trg_prevent_update_returned;

CREATE TRIGGER trg_prevent_update_returned
BEFORE UPDATE ON BookReservation
WHEN OLD.Status = 'returned'
     AND NEW.Status != OLD.Status
BEGIN
    SELECT RAISE(
        ABORT,
        'Cannot modify a returned reservation'
    );
END;

CREATE TRIGGER IF NOT EXISTS trg_reserved_at
AFTER INSERT ON BookReservation
BEGIN
    UPDATE BookReservation
    SET ReservedAt = datetime('now')
    WHERE BookReservationId = NEW.BookReservationId;
END;

CREATE TRIGGER IF NOT EXISTS trg_set_reserved_at
BEFORE INSERT ON BookReservation
BEGIN
    SELECT RAISE(ABORT, 'ReservedAt is set automatically')
    WHERE NEW.ReservedAt IS NOT NULL AND NEW.ReservedAt != datetime('now');
END;

-- Publishers
INSERT INTO Publisher (PublisherFirstName, PublisherLastName)
VALUES ('Penguin', 'Books');

INSERT INTO Publisher (PublisherFirstName, PublisherLastName)
VALUES ('Harper', 'Collins');

INSERT INTO Publisher (PublisherFirstName, PublisherLastName)
VALUES ('OReilly', 'Media');


-- Books
INSERT INTO Book (
    BookTitle,
    BookIsbn,
    BookPublicationYear,
    BookTotalCopies,
    BookDescription,
    BookShelf,
    BookLanguage
)
VALUES (
    '1984',
    '9780451524935',
    1949,
    5,
    'Dystopian novel by George Orwell',
    'A1',
    'English'
);

INSERT INTO Book (
    BookTitle,
    BookIsbn,
    BookPublicationYear,
    BookTotalCopies,
    BookDescription,
    BookShelf,
    BookLanguage
)
VALUES (
    'Harry Potter and the Philosophers Stone',
    '9780439708180',
    1997,
    4,
    'First Harry Potter novel',
    'A2',
    'English'
);

INSERT INTO Book (
    BookTitle,
    BookIsbn,
    BookPublicationYear,
    BookTotalCopies,
    BookDescription,
    BookShelf,
    BookLanguage
)
VALUES (
    'Clean Code',
    '9780132350884',
    2008,
    3,
    'Programming best practices',
    'T1',
    'English'
);

INSERT INTO Book (
    BookTitle,
    BookIsbn,
    BookPublicationYear,
    BookTotalCopies,
    BookDescription,
    BookShelf,
    BookLanguage
)
VALUES (
    'Dune',
    '9780441013593',
    1965,
    4,
    'Science fiction classic',
    'S1',
    'English'
);

-- BookAuthor
INSERT INTO BookAuthor VALUES (1,1);
INSERT INTO BookAuthor VALUES (2,2);
INSERT INTO BookAuthor VALUES (3,5);
INSERT INTO BookAuthor VALUES (4,6);

-- BookCategory
INSERT INTO BookCategory VALUES (1,1);
INSERT INTO BookCategory VALUES (1,3);
INSERT INTO BookCategory VALUES (2,1);
INSERT INTO BookCategory VALUES (3,5);
INSERT INTO BookCategory VALUES (4,3);

-- BookCollection
INSERT INTO BookCollection VALUES (1,1);
INSERT INTO BookCollection VALUES (2,1);
INSERT INTO BookCollection VALUES (3,5);
INSERT INTO BookCollection VALUES (4,3);

-- BookPublisher
INSERT INTO BookPublisher VALUES (1,1);
INSERT INTO BookPublisher VALUES (2,2);
INSERT INTO BookPublisher VALUES (3,3);
INSERT INTO BookPublisher VALUES (4,1);

CREATE TRIGGER IF NOT EXISTS trg_prevent_reserve_no_copies
BEFORE INSERT ON BookReservation
WHEN (
    SELECT BookTotalCopies
    FROM Book
    WHERE BookId = NEW.BookId
) <= 0
BEGIN
    SELECT RAISE(ABORT, 'No copies available for this book');
END;