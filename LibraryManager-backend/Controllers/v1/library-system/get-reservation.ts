import { Request, Response } from "express";
import { HelpAPIStructure } from "../../../types/HelpStructure";
import { Database } from "sqlite3";
import { z } from "zod";

const getReservationsSchema = z.object({
    reservationId: z.coerce.number().int().positive().optional(),
    bookId: z.coerce.number().int().positive().optional(),
    status: z.enum(["pending", "returned"]).optional(),

    page: z.coerce.number().int().positive().default(1),
    limit: z.coerce.number().int().positive().max(100).default(10),

    sort: z
        .enum([
            "BookReservationId",
            "BookId",
            "BookTitle",
            "Status",
            "ReservedAt",
            "DueDate",
            "ReturnedAt"
        ])
        .default("ReservedAt"),

    order: z.enum(["asc", "desc"]).default("desc"),
});

export async function execute(
    req: Request,
    res: Response,
    database: Database
): Promise<void> {
    const result = getReservationsSchema.safeParse(req.query);

    if (!result.success) {
        res.status(400).json({
            success: false,
            message: "Invalid query",
            errors: result.error.flatten(),
        });
        return;
    }

    const data = result.data;

    let sql = "SELECT * FROM ReservationDetail WHERE 1=1";
    const params: any[] = [];

    if (data.reservationId !== undefined) {
        sql += " AND BookReservationId = ?";
        params.push(data.reservationId);
    }

    if (data.bookId !== undefined) {
        sql += " AND BookId = ?";
        params.push(data.bookId);
    }

    if (data.status !== undefined) {
        sql += " AND Status = ?";
        params.push(data.status);
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
            reservations: rows,
            page: data.page,
            limit: data.limit,
        });
    });
}

export const help: HelpAPIStructure = {
    router: "library_system",
    host: "get_reservations",
    description: "Get reservations with filters",
    methode: "GET",
    version: "v1",
    active: true,
};