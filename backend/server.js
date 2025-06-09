const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const budgetRoutes = require('./routes/budget');
const expenseRoutes = require('./routes/expense');

const app = express();

app.use(cors());
app.use(express.json());

mongoose.connect(
  'mongodb+srv://kenzitjandra:8vsGGgJIqnAkRsV6@firstcluster.oadprm9.mongodb.net/?retryWrites=true&w=majority&appName=firstCluster',
  { useNewUrlParser: true, useUnifiedTopology: true }
).then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));

// Add this before your other routes
app.get('/', (req, res) => {
  res.send('Budget Tracker API is running');
});

app.use('/api', authRoutes);
app.use('/api/budget', budgetRoutes);
app.use('/api/expense', expenseRoutes);

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
