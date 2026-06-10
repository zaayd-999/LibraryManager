import { Request , Response } from "express";
import { HelpAPIStructure } from '../../../types/HelpStructure'
import { Database } from "sqlite3";
import { z } from 'zod';

/**
 * @param {Request} req
 * @param {Response} res
 * @param {Connection} database
 * @param {Transporter} transport
 * @returns {Promise<void>}
 * @description Create a new book
 */

const createBookSchema = z.object({
    BookTitle: z.string().min(1),
    AuthorFirstName: z.string().min(1),
    AuthorLastName: z.string().min(1),
    CategoryName: z.string().min(1),
    PublisherFirstName: z.string().min(1),
    PublisherLastName: z.string().min(1),
    BookDescription: z.string().min(1),
    BookShelf: z.string().min(1),
    BookLanguage: z.string().min(1),
    BookPublicationYear: z.number().int(),
    BookIsbn: z.string().optional(),
    BookTotalCopies: z.number().int().min(0),
});


export async function execute ( req : Request , res : Response , database : Database ) : Promise<void> {
    const result = createBookSchema.safeParse(req.body);
    if (!result.success) {
        res.status(400).json({
            message: "Invalid body",
            errors: result.error.flatten(),
        });
        return;
    }

    const data = result.data;

    database.serialize(() => {
        database.run("BEGIN TRANSACTION");
        database.run(`INSERT INTO Book (BookTitle,BookIsbn,BookPublicationYear,BookTotalCopies,BookDescription,BookShelf,BookLanguage) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [data.BookTitle, data.BookIsbn ?? null,data.BookPublicationYear, data.BookTotalCopies, data.BookDescription, data.BookShelf, data.BookLanguage],
        function(err) {
            if(err) {
                database.run("ROLLBACK");
                res.status(500).json({ message: err.message });
                return;
            }

            const bookId = this.lastID;

            database.run(`INSERT OR IGNORE INTO Author(AuthorFirstName, AuthorLastName) VALUES (?,?)`,[data.AuthorFirstName,data.AuthorLastName]);

            database.get(`SELECT AuthorId From Author
            WHERE AuthorFirstName = ? AND AuthorLastName = ?`
            ,[data.AuthorFirstName,data.AuthorLastName],
            (err,author:any) => {
                if (err || !author) {
                    database.run("ROLLBACK");
                    res.status(500).json({ message: err?.message ?? "Author not found" });
                    return;
                }

                database.run(` INSERT INTO BookAuthor (BookId, BookAuthorId) VALUES (?, ?)`,
                [bookId, author.AuthorId]);

                database.run(`INSERT OR IGNORE INTO Category(CategoryName) VALUES (?)`,[data.CategoryName]);

                database.get(`SELECT CategoryId FROM Category WHERE CategoryName = ?` , [data.CategoryName],(err,category:any) => {
                     if (err || !category) {
                        database.run("ROLLBACK");
                        res.status(500).json({ message: err?.message ?? "Category not found" });
                        return;
                    }

                    database.run(`INSERT INTO BookCategory (BookId, BookCategoryId) VALUES (?, ?)`,
                    [bookId, category.CategoryId]);
                    
                    database.run(`INSERT OR IGNORE INTO Publisher(PublisherFirstName, PublisherLastName) VALUES (?,?)`,[data.PublisherFirstName,data.PublisherLastName]);

                    database.get(`SELECT PublisherId FROM Publisher WHERE PublisherFirstName = ? AND PublisherLastName = ?`,
                    [data.PublisherFirstName,data.PublisherLastName]
                    ,((err,publisher:any) => {
                       if (err || !publisher) {
                            database.run("ROLLBACK");
                            res.status(500).json({ message: err?.message ?? "Publisher not found" });
                            return;
                        } 

                        database.run(`INSERT INTO BookPublisher(BookId, BookPublisherId) VALUES (?,?)`,[bookId,publisher.PublisherId] , (err) => {
                            if (err) {
                                database.run("ROLLBACK");
                                res.status(500).json({ message: err.message });
                                return;
                            }

                            database.run("COMMIT");

                            res.status(201).json({
                                message: "Book created successfully",
                                BookId: bookId,
                            });
                        })
                    }))
                })
            })

        });

    });
}

export const help : HelpAPIStructure = {
    router : "library_system",
    host : "create_book",
    description : "Create a new account",
    methode : "POST",
    version : "v1",
    active : true,
}