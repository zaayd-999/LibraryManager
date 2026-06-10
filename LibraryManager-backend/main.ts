import express , { Application , Request , Response , Router , json } from 'express';
import dotenv from 'dotenv';
import 'colors';

import { HelpAPIStructure , HelpRouteStructure } from './types/HelpStructure'
import { RouteFileStructure , APIFileStructure } from './types/fileStructure'
import { readdirSync } from 'fs';
import sqlite3, { Database, OPEN_READWRITE } from 'sqlite3';
dotenv.config();

let options = {};

const database : Database = new sqlite3.Database('./database/library.db', OPEN_READWRITE , (err) => {
    if (err) {
        console.error("Failed to establish connection to the database server:".red, err.message.red.bold);
        return;
    }
    console.log("Connected to the database server".green.bold);
    database.run("PRAGMA foreign_keys = ON;");
})


const ascii = require("ascii-table");

const app : Application = express();

import cors , { CorsOptions } from 'cors';

const allowedOrigins : string[] = [
  "http://localhost:3000",
  "http://127.0.0.1:3000",
];

const corsOptions: CorsOptions = {
  origin: (origin, callback) => {
    if(!origin) {
        //callback(new Error('CORS error : ' + (origin || "/")  + " is not allowed by CORS." ) , false);
        callback(null,true);
    }
    else if(!allowedOrigins.includes(origin)){
        callback(new Error('CORS error : ' + (origin || "/")  + " is not allowed by CORS." ) , false);
    }
    else {
        callback(null,true);
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
};


app.use(json());
app.use(cors(corsOptions));

import { urlencoded } from 'express';
import cookieParser from 'cookie-parser'
import compression , { CompressionOptions } from 'compression';
import { rateLimit } from 'express-rate-limit';

app.use(urlencoded({extended:true}));
app.use(cookieParser());

const limiter = rateLimit({
    windowMs: 60 * 1000,
    limit:100,
    standardHeaders:'draft-8',
    legacyHeaders:false,
    message : {
        error : "Too many requests from this IP, please try again after a minute.",
    } 
});

app.use(limiter);

let compressionOptions : CompressionOptions = {
    threshold : 1024,
}
app.use(compression());

import helmet from 'helmet';

app.use(helmet());

app.get("/" , (req:Request , res:Response) => {
    res.send("Hellow mate.")
});

app.listen(process.env.PORT, () => {
    console.log(`Server is running on port ${process.env.PORT}`.green.bold);
});

const RouteTable = new ascii("Route Table");
RouteTable.setHeading("Route", "Status","Enabled");

const APITable = new ascii("API Table");
APITable.setHeading("API", "Status", "Router" , "Method");

/**
 * @param {Router} Router
 * @param {string} route_name
 * @returns {Promise<void>}
 * @description Loads all Controllers for a specific route
 */

async function loadControllers(Router : Router , route_name : string , router_link : string) : Promise<void> {
    for ( let version of readdirSync('./Controllers') ) {
        for( let dir of readdirSync(`./Controllers/${version}`) ) {
            for ( let file of readdirSync(`./Controllers/${version}/${dir}`).filter(file => file.endsWith(".js") || file.endsWith(".ts")) ) {
                try {
                    const thisFile : APIFileStructure = require(`./Controllers/${version}/${dir}/${file}`.replace(".js","").replace(".ts",""));
                    if(thisFile.help && thisFile.execute){
                        if(thisFile.help.router == route_name){
                            (Router as any)[thisFile.help.methode.toLocaleLowerCase()](`/${thisFile.help.host}`, (req: Request, res: Response) => {
                                thisFile.execute(req, res, database);
                            });
                            APITable.addRow(`${file.replace(".ts","")}`, "✅", thisFile.help.router, thisFile.help.methode);
                        } 
                    } else {
                        APITable.addRow(`${file.replace(".ts","")}`, "❌", "help.router is missing" , "help.methode is missing");
                    }
                } catch (error) {
                    APITable.addRow(`${file.replace(".ts","")}`, "❌", "help.router is missing" , "help.methode is missing");
                }
                    
            }
        }
    }
}

/**
 * @returns {Promise<void>}
 * @description Loads all routes from the Routes directory
 */
async function loadRoutes() : Promise<void> {
    for (let dir of readdirSync("./Routes")) {
        let path = `./Routes/${dir}`;
        for( let file of readdirSync(path).filter(file => file.endsWith(".ts") ||file.endsWith(".js")) ) {
            path = `./Routes/${dir}/${file}`.replace(".ts","").replace(".js","");
            const RouterFile : RouteFileStructure = require(path);
            const thisFile : HelpRouteStructure = RouterFile.help;
            const { router , host , enabled , description , middleware } = thisFile;
            try {
                if(!enabled) {
                    app.get(`/api/${dir}/${host}` , (req : Request , res : Response) => {
                        res.status(200).json({
                            message : "This endpoint is disabled for maitenance",
                            description,
                        });
                    });
                } else {
                    app.use(`/api/${dir}/${host}`, middleware, router);
                    loadControllers(router , host , `/api/${dir}/${host}`);
                }
                RouteTable.addRow(`${host}`, "✅", enabled ? "Enabled" : "Disabled");
            } catch (error) {
                console.error(`Error loading route ${file}:`, (error as any).message.red.bold);
                RouteTable.addRow(`${host}`, "❌");
                return;   
            }
        }
    }
    console.log(RouteTable.toString().green.bold);
    console.log(APITable.toString().green.bold);
    console.log("All routes loaded successfully.".green.bold);
}

export { database };

loadRoutes();


