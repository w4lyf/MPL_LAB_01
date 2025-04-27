const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const svgCaptcha = require('svg-captcha');
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(bodyParser.json());
app.use('/captchas', express.static(path.join(__dirname, 'captchas'))); // Serve image folder

// In-memory session store
const sessions = {};

// 📩 Receive booking details
app.post('/api/send-booking', (req, res) => {
  const {
    train, from, to, selectedClass, quota, date
  } = req.body;

  const sessionId = uuidv4();
  const captcha = svgCaptcha.create({ 
    size: 5, 
    noise: 2, 
    background: '#fff4fc',
    fontSize: 45
  });
  const fileName = `${sessionId}.png`;
  const filePath = path.join(__dirname, 'captchas', fileName);

  // Convert SVG to PNG using sharp
  sharp(Buffer.from(captcha.data))
    .png()
    .toFile(filePath, (err) => {
      if (err) {
        console.error('Error creating CAPTCHA:', err);
        return res.status(500).json({ error: 'Failed to generate CAPTCHA' });
      }

      sessions[sessionId] = {
        expectedCaptcha: captcha.text,
        bookingDetails: { train, from, to, selectedClass, quota, date },
        captchaReady: true
      };

      res.json({ sessionId });
    });
});

// 🧾 Serve CAPTCHA info
app.get('/api/check-captcha', (req, res) => {
  const sessionId = req.query.sessionId;

  if (!sessionId || !sessions[sessionId]) {
    return res.status(404).json({ captchaAvailable: false });
  }

  const session = sessions[sessionId];

  if (session.captchaReady) {
    res.json({
      captchaAvailable: true,
      captchaUrl: `/captchas/${sessionId}.png`
    });
  } else {
    res.json({ captchaAvailable: false });
  }
});

// ✅ Submit and verify CAPTCHA
app.post('/api/submit-captcha', (req, res) => {
  const { sessionId, captchaInput } = req.body;

  if (!sessionId || !sessions[sessionId]) {
    return res.status(400).json({ error: 'Invalid session' });
  }

  const session = sessions[sessionId];
  const isCorrect = session.expectedCaptcha.toLowerCase() === captchaInput.toLowerCase();

  if (isCorrect) {
    res.json({
      message: 'Booking Successful!',
      booking: session.bookingDetails
    });

    // Optional cleanup
    fs.unlink(path.join(__dirname, 'captchas', `${sessionId}.png`), () => {});
    delete sessions[sessionId];
  } else {
    res.status(401).json({ error: 'Invalid CAPTCHA' });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
