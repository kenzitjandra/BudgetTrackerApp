const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const router = express.Router();

const JWT_SECRET = 'your_jwt_secret'; // change this in production

// Register
router.post('/register', async (req, res) => {
  console.log('\n=== NEW REGISTRATION ATTEMPT ===');
  console.log('Headers:', req.headers);
  console.log('Body:', req.body);

  const { email, username, password } = req.body;
  
  if (!email || !username || !password) {
    console.log('Validation failed - missing fields');
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    console.log('Checking for existing user...');
    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    
    if (existingUser) {
      console.log('User exists:', existingUser.email);
      return res.status(400).json({ message: 'Email or username already exists' });
    }

    console.log('Hashing password...');
    const hashedPassword = await bcrypt.hash(password, 10);
    
    console.log('Creating new user...');
    const user = new User({ email, username, password: hashedPassword });
    await user.save();
    
    console.log('User created successfully:', user.email);
    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '1h' });
    
    return res.status(201).json({ token, userId: user._id, message: 'User registered' });
    
  } catch (err) {
    console.error('SERVER ERROR:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    console.log('Login request received:', req.body);
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password required' });
    }

    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token, userId: user._id, message: 'Login successful' });
    
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
