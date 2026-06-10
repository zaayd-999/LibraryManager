import { Request, Response } from "express";
import { HelpAPIStructure } from "../../../types/HelpStructure";
import { Database } from "sqlite3";

/**
 * @param {Request} req
 * @param {Response} res
 * @param {Connection} database
 * @param {Transporter} transport
 * @returns {Promise<void>}
 * @description Create a new book
 */

export async function execute(req: Request,res: Response,database: Database): Promise<void> {
    const { title, author , publisher, category, collection, language, available } = req.query;
    let sql = "SELECT * FROM BookDetail WHERE 1=1";
    
    const params: any[] = [];

    if (title) {
        sql += ` AND BookTitle LIKE ?`;
        params.push(`%${title}%`);
    }

    if (author) {
        sql += ` AND Authors LIKE ?`;
        params.push(`%${author}%`);
    }

    if (publisher) {
        sql += ` AND Publishers LIKE ?`;
        params.push(`%${publisher}%`);
    }

    if (category) {
        sql += ` AND Categories LIKE ?`;
        params.push(`%${category}%`);
    }

    if (collection) {
        sql += ` AND Collections LIKE ?`;
        params.push(`%${collection}%`);
    }

    if (language) {
        sql += ` AND BookLanguage = ?`;
        params.push(language);
    }

    if (available === "true") {
        sql += ` AND BookTotalCopies > 0`;
    }

    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 10;
    const offset = (page-1) * limit;

    const sort = req.query.sort || "BookId";
    const order = req.query.order == "desc" ? "DESC" : "ASC";

    sql += ` ORDER BY ${sort} ${order}`;

    sql += ` LIMIT ? OFFSET ?`;
    
    params.push(limit,offset);

    database.all(sql,params,(err,rows) => {
        if(err) {
            return res.status(500).json({message:err.message})
        }
        res.json(rows);
    });
}

export const help: HelpAPIStructure = {
  router: "library_system",
  host: "get_books",
  description: "Create a new account",
  methode: "GET",
  version: "v1",
  active: true,
};
