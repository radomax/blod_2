import mysql from 'mysql2/promise';
import { DB_CONFIG } from './config.js';

let connection = null;

export async function getConnection() {
    if (!connection) {
        try {
            connection = await mysql.createConnection(DB_CONFIG);
            console.log('Connected to MySQL database');
        } catch (error) {
            console.error('Database connection failed:', error);
            throw error;
        }
    }
    return connection;
}

export async function query(sql, params = []) {
    try {
        const conn = await getConnection();
        const [rows] = await conn.execute(sql, params);
        return rows;
    } catch (error) {
        console.error('Database query error:', error);
        throw error;
    }
}

export async function closeConnection() {
    if (connection) {
        await connection.end();
        connection = null;
        console.log('Database connection closed');
    }
}