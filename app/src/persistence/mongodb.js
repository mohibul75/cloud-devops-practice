const { MongoClient } = require('mongodb');

let client;
let db;
let collection;

async function connect() {
  try {
    client = await MongoClient.connect(process.env.MONGODB_URI);
    db = client.db();
    collection = db.collection('todos');
    
    // Create indexes
    await collection.createIndex({ title: 1 });
    await collection.createIndex({ completed: 1 });
    
    console.log('Successfully connected to MongoDB');
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err);
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
