import bcrypt from 'bcrypt'
import nodemailer , { Transporter , SendMailOptions } from 'nodemailer';
import moment from 'moment';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import dotenv from 'dotenv';
import ms , { StringValue } from 'ms';
dotenv.config();
import { Connection } from 'mysql';

import { AccessTokenUserStructure , refreshTokenUserStructure } from './types/usersStructure';


/**
 * Hashes a password using the provided salt with bcrypte.
 * @param {string} password - The plain text password.
 * @param {string} salt - The salt to add before hashing.
 * @returns {string} The resulting bcrypte hash.
 */
export async function hash(password: string, salt: string): Promise<string> {
    const hashedPassword = await bcrypt.hash(password, salt);
    return hashedPassword;
}

/**
 * Generates a random alphanumeric salt string.
 * @param {number} [length=16] - The length of the salt.
 * @returns {string} The generated salt.
*/

export async function generateSalt(length:number = 16) : Promise<string> {
    let salt = await bcrypt.genSalt(length);
    return salt;
}

/**
 * Validates whether a password matches the stored hash.
 * @param {string} hashedPassword - The previously hashed password.
 * @param {string} password - The plain text password to check.
 * @param {string} salt - The salt used during hashing.
 * @returns {Pormise<boolean>} True if the password is correct, otherwise false.
 */
export async function check (hashedPassword : string, password : string) : Promise<boolean> {
	return await bcrypt.compare(password, hashedPassword);
};

/**
 * Sends an email using a configured nodemailer transport.
 * @param {nodemailer.Transporter} transport - The nodemailer transport instance.
 * @param {nodemailer.SendMailOptions} mailOptions - The email options (to, subject, html, etc.).
 * @param {Function} callback - Callback executed after sending the email.
 */
export function sendMail (transport : Transporter , mailOptions :SendMailOptions , callback : CallableFunction) : void {
	transport.sendMail(mailOptions, (err, info) => {
		callback(err, info);
	});
};



/**
 * Maps a role ID to its corresponding role name.
 * @param {number} roleID - The role identifier (0 = Member, 1 = Hotel Owner, 2 = Admin).
 * @returns {string} The name of the role.
 */
export function getUserRole (roleID : number) : "Member" | "Hotel Owner" | "Admin" {
	if (roleID === 1) return "Hotel Owner";
	if (roleID === 2) return "Admin";
    return "Member";
}

/**
 * Returns the current time formatted as `YYYY-DD-MM at hh:mm A`.
 * @returns {string} The formatted current time.
 */

export function getTime(time: number | Date = Date.now()) : string  {
    return moment(time).format("YYYY-DD-MM [at] hh:mm A");
};


/**
 * Generates a short-lived access token for a user.
 * @param {Object} user - The user payload to encode into the token.
 * @returns {string} The generated JWT access token.
 */

export function generateAccessToken( user : AccessTokenUserStructure ) : string {
    if (!process.env.ACCESS_TOKEN_SECRET) {
        throw new Error("ACCESS_TOKEN_SECRET is not defined");
    }
    let options : jwt.SignOptions = {
        expiresIn : '10m',
        
    };
    const accessToken = jwt.sign( user , process.env.ACCESS_TOKEN_SECRET , options );
    return accessToken;
}

/**
 * Generates a refresh token for a user.
 * @param {Object} user - The user payload to encode into the token.
 * @returns {string} The generated JWT refresh token.
 */

export function generateRefreshToken( user : refreshTokenUserStructure ) : string {
    if (!process.env.REFRESH_TOKEN_SECRET) {
        throw new Error("ACCESS_TOKEN_SECRET is not defined");
    }
    let options : jwt.SignOptions = {
        expiresIn : "20d",
        
    };
    const accessToken = jwt.sign( user , process.env.REFRESH_TOKEN_SECRET , options );
    return accessToken;
}

/**
 * @param token 
 * @param database 
 * @returns Check if the token is blocked
 */

export function checkIfBlocked(token: string, database: Connection): Promise<boolean> {
    return new Promise((resolve, reject) => {
        database.query('SELECT * FROM blocked_tokens WHERE token = ?', [token], (err, result) => {
            if (err) {
                console.error("DB error:", err);
                return resolve(false);
            }

            if (result.length > 0) {
                resolve(true);
            } else {
                resolve(false);
            }
        });
    });
}