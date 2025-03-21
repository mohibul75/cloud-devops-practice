// Construct MongoDB URI if credentials are available
if (process.env.MONGODB_USERNAME && process.env.MONGODB_PASSWORD) {
  process.env.MONGODB_URI = `mongodb://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@mongodb.dev.svc.cluster.local:27017/todos?authSource=admin`;
}

if (process.env.MONGODB_URI) module.exports = require('./mongodb');
else if (process.env.MYSQL_HOST) module.exports = require('./mysql');
else module.exports = require('./sqlite');
