import express from 'express';
import { generateArticle } from '../services/aiClient.js';
import Article from '../models/article.js';

const router = express.Router();

/**
 * GET /api/articles - Get all articles
 */
router.get('/', async (req, res) => {
  try {
    const articles = await Article.findAll();
    
    // Generate sample articles if database is empty
    if (articles.length === 0) {
      await generateSampleArticles();
      const newArticles = await Article.findAll();
      return res.json(newArticles);
    }
    
    res.json(articles);
  } catch (error) {
    console.error('Error fetching articles:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * GET /api/articles/:id - Get single article
 */
router.get('/:id', async (req, res) => {
  try {
    const article = await Article.incrementViews(req.params.id);
    
    if (!article) {
      return res.status(404).json({ error: 'Article not found' });
    }
    
    res.json(article);
  } catch (error) {
    console.error('Error fetching article:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * POST /api/articles/generate - Generate new article
 */
router.post('/generate', async (req, res) => {
  try {
    const { topic = 'Tecnologia', style = 'informative' } = req.body;
    
    const articleData = await generateArticle(topic, style);
    const newArticle = await Article.create(articleData);
    
    res.status(201).json(newArticle);
  } catch (error) {
    console.error('Error generating article:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * DELETE /api/articles/:id - Delete article
 */
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Article.delete(req.params.id);
    
    if (!deleted) {
      return res.status(404).json({ error: 'Article not found' });
    }
    
    res.json(deleted);
  } catch (error) {
    console.error('Error deleting article:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * Generate sample articles on startup
 */
async function generateSampleArticles() {
  const topics = [
    'Inteligência Artificial',
    'Desenvolvimento Web',
    'Cloud Computing',
    'Cibersegurança',
    'Machine Learning'
  ];
  
  console.log('Generating sample articles...');
  
  for (const topic of topics) {
    try {
      const articleData = await generateArticle(topic);
      await Article.create(articleData);
      console.log(`✓ Article created: ${articleData.title}`);
    } catch (error) {
      console.error(`Failed to generate article for ${topic}:`, error.message);
    }
  }
  
  console.log('Sample articles generation completed');
}

export default router;
