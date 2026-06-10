import { Request , Response } from "express";
import { HelpAPIStructure } from '../../../types/HelpStructure'
import { Database } from "sqlite3";
import { success, z } from 'zod';

/**
 * @param {Request} req
 * @param {Response} res
 * @param {Connection} database
 * @param {Transporter} transport
 * @returns {Promise<void>}
 * @description Update book
 */

const updateBookSchema = z.object({
    BookId: z.number().int(),

    BookTitle: z.string().optional(),
    BookIsbn: z.string().optional(),
    BookPublicationYear: z.number().int().optional(),
    BookTotalCopies: z.number().int().min(0).optional(),
    BookDescription: z.string().optional(),
    BookShelf: z.string().optional(),
    BookLanguage: z.string().optional(),
});

export async function execute ( req : Request , res : Response , database : Database ) : Promise<void> {
    const result = updateBookSchema.safeParse(req.body);

    if(!result.success) {
        res.status(400).json({
            success: false,
            errors: result.error.flatten()
        });
        return;
    }

    const { BookId, ...fields } = result.data;

    const updates: string[] = [];
    const values: any[] = [];

    for(const [key,value] of Object.entries(fields)) {
        if (value !== undefined) {
            updates.push(`${key} = ?`);
            values.push(value);
        }
    }

    if (updates.length === 0) {
        res.status(400).json({
            success: false,
            message: "No fields to update",
        });
        return;
    }

    values.push(BookId);

    database.run(`UPDATE Book SET ${updates.join(", ")} WHERE BookId = ?` , values , function (err) {
        if (err) {
            res.status(500).json({
                success: false,
                message: err.message,
            });
            return;
        }

        if (this.changes === 0) {
            res.status(404).json({
                success: false,
                message: "Book not found",
            });
            return;
        }

        res.json({
            success: true,
            message: "Book updated successfully",
        });
        });
}

export const help: HelpAPIStructure = {
    router: "library_system",
    host: "update_book",
    description: "Update a book by ID",
    methode: "POST",
    version: "v1",
    active: true,
};