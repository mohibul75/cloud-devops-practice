// Construct MongoDB URI if credentials are available
if (process.env.MONGODB_HOST && process.env.MONGODB_USERNAME && process.env.MONGODB_PASSWORD) {
  const host = process.env.MONGODB_HOST;
  const port = process.env.MONGODB_PORT || '27017';
  const database = process.env.MONGODB_DATABASE || 'todos';
  const username = encodeURIComponent(process.env.MONGODB_USERNAME);
  const password = encodeURIComponent(process.env.MONGODB_PASSWORD);
  const replicaSet = process.env.MONGODB_REPLICA_SET || 'myReplicaSet';

  process.env.MONGODB_URI = `mongodb://${username}:${password}@${host}:${port}/${database}?authSource=admin&replicaSet=${replicaSet}`;
  console.log('MongoDB connection string constructed (credentials masked):', 
    process.env.MONGODB_URI.replace(password, '****'));
}

if (process.env.MONGODB_URI) module.exports = require('./mongodb');
else if (process.env.MYSQL_HOST) module.exports = require('./mysql');
else module.exports = require('./sqlite');
