const express = require('express');
const Expense = require('../models/Expense');
const router = express.Router();

// Add expense
router.post('/', async (req, res) => {
  const { userId, date, amount, category } = req.body;

  try {
    const expense = new Expense({ userId, date, amount, category });
    await expense.save();
    res.json(expense);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get expenses
router.get('/:userId', async (req, res) => {
  try {
    const expenses = await Expense.find({ userId: req.params.userId });
    res.json(expenses.map(exp => ({
        ...exp._doc,
        _id: exp._id.toString() // 👈 make sure _id is a plain string
    })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Expense.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: 'Expense not found' });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});


module.exports = router;
