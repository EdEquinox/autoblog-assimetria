import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import articlesRouter from './routes/articles.js';
import { initDatabase } from './config/database.js';

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
// Configure CORS for production
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.FRONTEND_URL || '*'
    : '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
app.use(express.json());

// Log CORS configuration
console.log('CORS configured for origin:', corsOptions.origin);

// Routes
app.use('/api/articles', articlesRouter);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: err.message });
});

// Initialize database and start server
try {
  await initDatabase();
  
  app.listen(PORT, () => {
    console.log(`Backend server running on http://localhost:${PORT}`);
    console.log(`API: http://localhost:${PORT}/api/articles`);
  });
} catch (error) {
  console.error('Failed to start server:', error);
  process.exit(1);
}

export default app;
