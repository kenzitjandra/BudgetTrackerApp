const mongoose = require('mongoose');

const expenseSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  date: String, // '2025-06-08'
  amount: Number,
  category: String
});

module.exports = mongoose.model('Expense', expenseSchema);
