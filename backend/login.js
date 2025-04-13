import express from 'express';
import mongoose from 'mongoose';
const app = express();

// Add middleware to parse JSON bodies
app.use(express.json());

// Encode special characters in the password
mongoose.connect('mongodb+srv://abhinav:abc%40123@abhinav.bkjsq.mongodb.net/railway_app')
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

const User = mongoose.model('User', {
  username: String,
  password: String
});

app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  
  try {
    const user = await User.findOne({ username, password });
    if (user) {
      res.json({ success: true });
      console.log("success")
    } else {
      res.status(401).json({ success: false });
    }
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false });
  }
});

// Add error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});