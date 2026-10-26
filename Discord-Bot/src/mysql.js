const env = require("dotenv").config({ path: require("node:path").join(__dirname, "../.env") }).parsed || {};
const mysql = require("mysql2/promise");

const pool = mysql.createPool({
    host: process.env.DB_HOST || env.HOST || process.env.HOST || "localhost",
    port: Number(process.env.DB_PORT || env.PORT || 3306),
    user: process.env.DB_USER || env.USER || process.env.USER || "root",
    database: process.env.DB_NAME || env.DATABASE || process.env.DATABASE || "dtrp",
    password: process.env.DB_PASSWORD ?? env.PASSWORD ?? process.env.PASSWORD ?? "",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = pool;

