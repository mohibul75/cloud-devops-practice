const { MongoClient } = require('mongodb');

let client;
let db;
let collection;

async function connect() {
  try {
    // Construct MongoDB URI with replica set
    const uri = `mongodb://${process.env.MONGODB_USERNAME}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_HOST}:${process.env.MONGODB_PORT}/${process.env.MONGODB_DATABASE}?authSource=admin&replicaSet=myReplicaSet&directConnection=false`;
    console.log('MongoDB connection string constructed (credentials masked):', uri.replace(/:[^:@]*@/, ':****@'));

    client = await MongoClient.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
    });
    
    db = client.db(process.env.MONGODB_DATABASE);
    collection = db.collection('todos');
    
    // Create indexes
    await collection.createIndex({ title: 1 });
    await collection.createIndex({ completed: 1 });
    
    console.log('Successfully connected to MongoDB');
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err.name, err.message, err.stack);
    throw err;
  }
}

async function init() {
  await connect();
}

async function listTodos() {
  return await collection.find({}).toArray();
}

async function createTodo(title) {
  const todo = {
    title,
    completed: false,
    created_at: new Date(),
    updated_at: new Date()
  };
  
  const result = await collection.insertOne(todo);
  return { id: result.insertedId, ...todo };
}

async function getTodo(id) {
  return await collection.findOne({ _id: id });
}

async function updateTodo(id, data) {
  const result = await collection.findOneAndUpdate(
    { _id: id },
    { 
      $set: { 
        ...data,
        updated_at: new Date()
      } 
    },
    { returnDocument: 'after' }
  );
  return result.value;
}

async function deleteTodo(id) {
  await collection.deleteOne({ _id: id });
}

async function deleteAll() {
  await collection.deleteMany({});
}

module.exports = {
  init,
  listTodos,
  createTodo,
  getTodo,
  updateTodo,
  deleteTodo,
  deleteAll
};
