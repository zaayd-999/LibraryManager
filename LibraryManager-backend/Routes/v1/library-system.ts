import {Router , Response , Request , NextFunction} from 'express'
import { HelpRouteStructure } from '../../types/HelpStructure'

const librarySystemRouter : Router = Router();

const librarySystemMiddleware = (req:Request, res:Response, next:NextFunction) => {
    next();
}

export const help : HelpRouteStructure = {
    router : librarySystemRouter,
    host : 'library_system',
    enabled : true,
    description : 'Handles account-related operations such as user registration, login, and profile management.',
    middleware : librarySystemMiddleware
}