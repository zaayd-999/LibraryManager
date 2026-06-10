export interface User {
    user_id : number,
    first_name : string,
    last_name : string,
    email : string,
    phone : string,
    address : string,
    city : string,
    postal_code : number,
    activated : number,
    account_type : 0 | 1 | 2,
}

export interface databaseUserStructure {
    user_id : number,
    first_name : string,
    last_name : string,
    email : string,
    phone : string,
    address : string,
    city : string,
    postal_code : number,
    activated : number,
    account_type : 0 | 1 | 2,
    password : string,
    refresh_token : string | null,
}


export interface AccessTokenUserStructure {
    user_id : number,
    first_name : string,
    last_name : string,
    email : string,
    phone : string,
    address : string,
    city : string,
    postal_code : number,
    activated : number,
    account_type : "Member" | "Hotel Owner" | "Admin",
}

export interface refreshTokenUserStructure {
    user_id : number,
    first_name : string,
    last_name : string,
    email : string,
    phone : string,
    address : string,
    city : string,
    postal_code : number,
    activated : number,
    account_type : "Member" | "Hotel Owner" | "Admin",
    UUID : string,
}

export interface accessTokenStructure {
    user_id : number,
    first_name : string,
    last_name : string,
    email : string,
    phone : string,
    address : string,
    city : string,
    postal_code : number,
    activated : number,
    account_type : "Member" | "Hotel Owner" | "Admin",
    iat : number,
    exp : number,
}

export interface refreshTokenStructure {
    user_id : number,
    first_name : string,
    last_name : string,
    email : string,
    phone : string,
    address : string,
    city : string,
    postal_code : number,
    activated : number,
    account_type : "Member" | "Hotel Owner" | "Admin",
    UUID : string,
    iat : number,
    exp : number,
}