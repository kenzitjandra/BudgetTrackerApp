const express = require('express');
const Budget = require('../models/Budget');
const router = express.Router();

// Set or update budget
router.post('/', async (req, res) => {
  const { userId, totalBudget, categorySplit, month } = req.body;

  try {
    const budget = await Budget.findOneAndUpdate(
      { userId, month },
      { totalBudget, categorySplit },
      { upsert: true, new: true }
    );
    res.json(budget);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get budget
router.get('/:userId/:month', async (req, res) => {
  try {
    const { userId, month } = req.params;
    const budget = await Budget.findOne({ userId, month });

    if (!budget) {
      return res.status(404).json({ message: 'Budget not found' });
    }

    res.json(budget);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:userId/:month', async (req, res) => {
  try {
    const { userId, month } = req.params;
    const result = await Budget.findOneAndDelete({ userId, month });
    if (!result) return res.status(404).json({ message: 'Budget not found' });
    res.json({ message: 'Budget deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
