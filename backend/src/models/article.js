import * as db from '../config/database.js';

/**
 * Article model for PostgreSQL
 */

class Article {
  /**
   * Create a new article
   */
  static async create({ title, description, content, tags, status = 'published' }) {
    const tagsString = Array.isArray(tags) ? tags.join(',') : tags;
    
    const result = await db.query(
      `INSERT INTO articles (title, description, content, tags, status, views, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, 0, NOW(), NOW())
       RETURNING *`,
      [title, description, content, tagsString, status]
    );
    
    return this.formatArticle(result.rows[0]);
  }

  /**
   * Find all articles
   */
  static async findAll({ status = 'published', limit = 100, offset = 0 } = {}) {
    const result = await db.query(
      `SELECT * FROM articles 
       WHERE status = $1 
       ORDER BY created_at DESC 
       LIMIT $2 OFFSET $3`,
      [status, limit, offset]
    );
    
    return result.rows.map(this.formatArticle);
  }

  /**
   * Find article by ID
   */
  static async findById(id) {
    const result = await db.query(
      'SELECT * FROM articles WHERE id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return null;
    }
    
    return this.formatArticle(result.rows[0]);
  }

  /**
   * Update article views
   */
  static async incrementViews(id) {
    const result = await db.query(
      `UPDATE articles 
       SET views = views + 1, updated_at = NOW() 
       WHERE id = $1 
       RETURNING *`,
      [id]
    );
    
    return result.rows.length > 0 ? this.formatArticle(result.rows[0]) : null;
  }

  /**
   * Delete article
   */
  static async delete(id) {
    const result = await db.query(
      'DELETE FROM articles WHERE id = $1 RETURNING *',
      [id]
    );
    
    return result.rows.length > 0 ? this.formatArticle(result.rows[0]) : null;
  }

  /**
   * Count articles
   */
  static async count({ status = 'published' } = {}) {
    const result = await db.query(
      'SELECT COUNT(*) FROM articles WHERE status = $1',
      [status]
    );
    
    return Number.parseInt(result.rows[0].count);
  }

  /**
   * Format article from database
   */
  static formatArticle(row) {
    if (!row) return null;
    
    return {
      id: row.id.toString(),
      title: row.title,
      description: row.description,
      content: row.content,
      tags: row.tags ? row.tags.split(',') : [],
      status: row.status,
      views: row.views,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };
  }
}

export default Article;
