import { Request , Response } from "express";
import { HelpAPIStructure } from '../../../types/HelpStructure'
import { Database } from "sqlite3";
import { z } from 'zod';

/**
 * @param {Request} req
 * @param {Response} res
 * @param {Database} database
 * @returns {Promise<void>}
 * @description Create a new book
 */

const reserveSchema = z.object({
    BookId: z.number().int().positive(),
    DurationDays: z.number().int().positive().optional(),
});

export async function execute ( req : Request , res : Response , database : Database ) : Promise<void> {
    const result = reserveSchema.safeParse(req.body);

    if (!result.success) {
        res.status(400).json({
            success: false,
            message: "Invalid body",
            errors: result.error.flatten(),
        });
        return;
    }

    const { BookId, DurationDays } = result.data;

    database.run(`INSERT INTO BookReservation (BookId, DurationDays) VALUES (?,?)`,[BookId,DurationDays],function(err) {
        if (err) {
            res.status(400).json({
            success: false,
            message: err.message,
            });
            return;
        }
        res.status(201).json({
            success: true,
            message: "Book reserved successfully",
            BookReservationId: this.lastID,
        });
    });
}

export const help : HelpAPIStructure = {
    router : "library_system",
    host : "create_reservation",
    description : "Create a new reservation",
    methode : "POST",
    version : "v1",
    active : true,
}