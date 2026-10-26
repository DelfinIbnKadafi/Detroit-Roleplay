require("dotenv").config();
const mysql = require("mysql2/promise");

const pool = mysql.createPool({
    host: process.env.HOST || "localhost",
    user: process.env.USER || "root",
    database: process.env.DATABASE || "dtrp",
    password: process.env.PASSWORD || "",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

if (pool) {
    console.log("[DTRP-BOT] Database connected!");
} else {
    console.log("[DTRP-BOT] Database connection failed!");
}

module.exports = pool;

