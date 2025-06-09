const mongoose = require('mongoose');

const budgetSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  totalBudget: Number,
  categorySplit: Object, // e.g., { food: 200, transport: 150, etc. }
  month: String // e.g., '2025-06'
});

module.exports = mongoose.model('Budget', budgetSchema);
