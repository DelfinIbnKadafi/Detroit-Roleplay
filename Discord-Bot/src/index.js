console.log("Starting BOT...");

require('dotenv').config()

// pakai process.env.nama untuk mendapatkan value .env

// connect mysql
const mysql = require("mysql2/promise");

const username_db = process.env.DB_USN;
const host_db = process.env.DB_HOST;
const pass_db = process.env.DB_PASS;
const name_db = process.env.DB_NAME;

const connection = await mysql.createConnection(
    {
        host: host_db,
        user: username_db,
        database: name_db,
        password: pass_db
    }
);