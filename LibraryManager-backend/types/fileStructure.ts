import { HelpAPIStructure , HelpRouteStructure } from './HelpStructure'
export interface APIFileStructure {
    execute : Function,
    help : HelpAPIStructure,
}

export interface RouteFileStructure {
    help : HelpRouteStructure,
}