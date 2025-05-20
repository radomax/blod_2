// Database configuration
const DB_CONFIG = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'rado',
    password: process.env.DB_PASSWORD || '2505',
    database: process.env.DB_NAME || 'blodtrykk',
    port: process.env.DB_PORT || 3306
};

export { DB_CONFIG };