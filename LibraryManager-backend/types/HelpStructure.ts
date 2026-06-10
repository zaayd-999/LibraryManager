export interface HelpAPIStructure {
    router : string,
    host : string,
    version : string,
    description : string,
    methode : string,
    active : boolean,
}

import { Router , RequestHandler } from "express";

export interface HelpRouteStructure {
    router : Router,
    host : string,
    enabled : boolean,
    description : string,
    middleware : RequestHandler,
}