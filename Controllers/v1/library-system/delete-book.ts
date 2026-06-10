import { Request, Response } from "express";
import { Database } from "sqlite3";
import { z } from "zod";
import { HelpAPIStructure } from '../../../types/HelpStructure'


const deleteBookSchema = z.object({
    BookId: z.number().int().positive()
});

export async function execute(
    req: Request,
    res: Response,
    database: Database
): Promise<void> {

    const result = deleteBookSchema.safeParse(req.body);

    if (!result.success) {
        res.status(400).json({
            success: false,
            errors: result.error.flatten()
        });
        return;
    }

    const { BookId } = result.data;

    database.run(
        `DELETE FROM Book WHERE BookId = ?`,
        [BookId],
        function (err) {
            if (err) {
                res.status(500).json({
                    success: false,
                    message: err.message
                });
                return;
            }

            if (this.changes === 0) {
                res.status(404).json({
                    success: false,
                    message: "Book not found"
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: "Book deleted successfully"
            });
        }
    );
}

export const help: HelpAPIStructure = {
    router: "library_system",
    host: "delete_book",
    description: "Delete a book by ID",
    methode: "POST",
    version: "v1",
    active: true,
};