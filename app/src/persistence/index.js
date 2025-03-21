if (process.env.MONGODB_URI) module.exports = require('./mongodb');
else if (process.env.MYSQL_HOST) module.exports = require('./mysql');
else module.exports = require('./sqlite');
