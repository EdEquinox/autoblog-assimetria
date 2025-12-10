import cron from 'node-cron';
import { generateArticle } from './aiClient.js';

/**
 * Schedule article generation at regular intervals
 * Default: every day at 2 AM
 */
function scheduleArticleGeneration(db, interval = '0 2 * * *') {
  console.log(`Scheduling article generation: ${interval}`);
  
  cron.schedule(interval, async () => {
    console.log('Running scheduled article generation...');
    try {
      await generateAndSaveArticle(db, 'Tecnologia');
      await generateAndSaveArticle(db, 'Inteligência Artificial');
      await generateAndSaveArticle(db, 'Desenvolvimento Web');
    } catch (error) {
      console.error('Error in scheduled article generation:', error);
    }
  });
}

/**
 * Generate article and save to database
 */
async function generateAndSaveArticle(db, topic) {
  try {
    const article = await generateArticle(topic);
    
    // Save to database (PostgreSQL or MongoDB)
    if (db && db.query) {
      // PostgreSQL
      await db.query(
        'INSERT INTO articles (title, description, content, tags, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
        [article.title, article.description, article.content, article.tags.join(','), 'published']
      );
    } else if (db && db.collection) {
      // MongoDB
      await db.collection('articles').insertOne({
        ...article,
        status: 'published',
        createdAt: new Date(),
        updatedAt: new Date(),
        views: 0
      });
    }
    
    console.log(`Article saved: ${article.title}`);
    return article;
  } catch (error) {
    console.error(`Error generating article for "${topic}":`, error.message);
    throw error;
  }
}

/**
 * Manually trigger article generation (for API endpoint)
 */
async function generateArticleManually(db, topic = 'Tecnologia') {
  return generateAndSaveArticle(db, topic);
}

export {
  scheduleArticleGeneration,
  generateAndSaveArticle,
  generateArticleManually
};