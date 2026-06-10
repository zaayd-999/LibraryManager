import { Request, Response } from "express";
import { HelpAPIStructure } from "../../../types/HelpStructure";
import { Database } from "sqlite3";
import { z } from "zod";

const getBooksSchema = z.object({
    bookId: z.coerce.number().int().positive().optional(),
    title: z.string().optional(),
    author: z.string().optional(),
    publisher: z.string().optional(),
    category: z.string().optional(),
    collection: z.string().optional(),
    language: z.string().optional(),
    available: z.enum(["true", "false"]).optional(),

    page: z.coerce.number().int().positive().default(1),
    limit: z.coerce.number().int().positive().max(100).default(10),

    sort: z
        .enum([
            "BookId",
            "BookTitle",
            "BookPublicationYear",
            "BookTotalCopies",
            "BookLanguage"
        ])
        .default("BookId"),

    order: z.enum(["asc", "desc"]).default("asc"),
});

export async function execute(
    req: Request,
    res: Response,
    database: Database
): Promise<void> {
    const result = getBooksSchema.safeParse(req.query);

    if (!result.success) {
        res.status(400).json({
            success: false,
            message: "Invalid query",
            errors: result.error.flatten(),
        });
        return;
    }

    const data = result.data;

    let sql = "SELECT * FROM BookDetail WHERE 1=1";
    const params: any[] = [];

    if (data.bookId !== undefined) {
        sql += " AND BookId = ?";
        params.push(data.bookId);
    }

    if (data.title) {
        sql += " AND BookTitle LIKE ?";
        params.push(`%${data.title}%`);
    }

    if (data.author) {
        sql += " AND Authors LIKE ?";
        params.push(`%${data.author}%`);
    }

    if (data.publisher) {
        sql += " AND Publishers LIKE ?";
        params.push(`%${data.publisher}%`);
    }

    if (data.category) {
        sql += " AND Categories LIKE ?";
        params.push(`%${data.category}%`);
    }

    if (data.collection) {
        sql += " AND Collections LIKE ?";
        params.push(`%${data.collection}%`);
    }

    if (data.language) {
        sql += " AND BookLanguage = ?";
        params.push(data.language);
    }

    if (data.available === "true") {
        sql += " AND BookTotalCopies > 0";
    }

    const offset = (data.page - 1) * data.limit;

    sql += ` ORDER BY ${data.sort} ${data.order === "desc" ? "DESC" : "ASC"}`;
    sql += " LIMIT ? OFFSET ?";

    params.push(data.limit, offset);

    database.all(sql, params, (err, rows) => {
        if (err) {
            res.status(500).json({
                success: false,
                message: err.message,
            });
            return;
        }

        res.json({
            success: true,
            books: rows,
            page: data.page,
            limit: data.limit,
        });
    });
}

export const help: HelpAPIStructure = {
    router: "library_system",
    host: "get_books",
    description: "Get books with filters",
    methode: "GET",
    version: "v1",
    active: true,
};