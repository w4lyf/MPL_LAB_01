import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { spawn } from 'child_process';
import { v4 as uuidv4 } from 'uuid';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
app.use(cors());
app.use(bodyParser.json());

const API_FILE_PATH = path.join(__dirname, 'api.mjs');
const CAPTCHA_FILE_PATH = path.join(__dirname, 'captcha.png');
const activeProcesses = {}; // Store active api.mjs processes

app.post('/api/send-booking', (req, res) => {
  try {
    const { train, from, to, selectedClass, quota, date } = req.body;
    console.log("Received booking details:", req.body);

    const sessionId = uuidv4();
    console.log(`Starting api.mjs in a new terminal with session ID: ${sessionId}`);

    let processInstance;

    if (process.platform === "win32") {
      processInstance = spawn('cmd.exe', ['/c', 'start', 'cmd.exe', '/k', `node ${API_FILE_PATH}`], { stdio: 'ignore', detached: true });
    } else {
      processInstance = spawn('x-terminal-emulator', ['-e', `node`, API_FILE_PATH], { stdio: 'ignore', detached: true });
    }

    activeProcesses[sessionId] = {
      process: processInstance,
      output: [],
      isComplete: false,
      captchaAvailable: false
    };

    res.json({ message: 'Booking started in a new terminal. Manually enter the CAPTCHA.', sessionId });

  } catch (error) {
    console.error('Error starting booking:', error);
    res.status(500).json({ error: 'Failed to process booking' });
  }
});







// Check if CAPTCHA is available
app.get('/api/check-captcha', (req, res) => {
  if (fs.existsSync(CAPTCHA_FILE_PATH)) {
    console.log("Forwarding captcha.png to Flutter");
    res.json({ captchaAvailable: true, captchaUrl: '/captcha.png' });
  } else {
    res.json({ captchaAvailable: false });
  }
});

// Serve CAPTCHA image
app.get('/captcha.png', (req, res) => {
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Expires', '0');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Surrogate-Control', 'no-store');
  
  res.sendFile(CAPTCHA_FILE_PATH);
});

// 



// Send CAPTCHA input to api.mjs
app.post('/api/submit-captcha', (req, res) => {
  const { sessionId, captchaInput } = req.body;

  if (!sessionId || !activeProcesses[sessionId]) {
    return res.status(404).json({ error: 'Session not found' });
  }

  console.log(`Manually enter this CAPTCHA in the open terminal: ${captchaInput}`);

  // ✅ Run enter_captcha.py after logging the message
  const pythonProcess = spawn('python', ['enter_captcha.py', captchaInput]);

  pythonProcess.stdout.on('data', (data) => {
    console.log(`[Python Output] ${data.toString().trim()}`);
  });

  pythonProcess.stderr.on('data', (data) => {
    console.error(`[Python Error] ${data.toString().trim()}`);
  });

  pythonProcess.on('exit', (code) => {
    console.log(`Python script enter_captcha.py exited with code ${code}`);
  });

  res.json({ message: 'CAPTCHA sent to enter_captcha.py for auto-entry' });
});


const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
