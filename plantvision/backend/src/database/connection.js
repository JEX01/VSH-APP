const knex = require('knex');
const knexConfig = require('../../knexfile');
const logger = require('../utils/logger');

const environment = process.env.NODE_ENV || 'development';
const config = knexConfig[environment];

const db = knex(config);

// Test database connection
db.raw('SELECT 1')
  .then(() => {
    logger.info('✅ Database connection established successfully');
  })
  .catch((err) => {
    logger.error('❌ Database connection failed:', err.message);
    process.exit(1);
  });

module.exports = db;