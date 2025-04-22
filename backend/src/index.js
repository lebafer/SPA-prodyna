const express = require('express');
const mongoose = require('mongoose');
const app = express();

const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/test';

mongoose.connect(mongoUri, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB');
}).catch((err) => {
  console.error('MongoDB connection error:', err);
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Backend listening at http://localhost:${port}`);
});