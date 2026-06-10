import { Request, Response } from "express";
import { HelpAPIStructure } from "../../../types/HelpStructure";
import { Database } from "sqlite3";
import { z } from "zod";

const returnBookSchema = z.object({
  BookReservationId: z.number().int().positive(),
});

export async function execute(
  req: Request,
  res: Response,
  database: Database,
): Promise<void> {
  const result = returnBookSchema.safeParse(req.body);

  if (!result.success) {
    res.status(400).json({
      success: false,
      message: "Invalid body",
      errors: result.error.flatten(),
    });
    return;
  }

  const { BookReservationId } = result.data;

  database.run(
    `
        UPDATE BookReservation
        SET Status = 'returned'
        WHERE BookReservationId = ?
        `,
    [BookReservationId],
    function (err) {
      if (err) {
        res.status(400).json({
          success: false,
          message: err.message,
        });
        return;
      }

      if (this.changes === 0) {
        res.status(404).json({
          success: false,
          message: "Reservation not found",
        });
        return;
      }

      res.json({
        success: true,
        message: "Book returned successfully",
      });
    },
  );
}

export const help: HelpAPIStructure = {
  router: "library_system",
  host: "return_book",
  description: "Return a reserved book",
  methode: "POST",
  version: "v1",
  active: true,
};
