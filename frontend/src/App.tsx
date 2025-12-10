import { useState, useEffect } from 'react'
import './App.css'
import { getArticles, getArticleById, generateArticle } from './api/articles'

interface Article {
  id: string;
  title: string;
  description?: string;
  content?: string;
  [key: string]: any;
}

function App() {
  const [articles, setArticles] = useState<Article[]>([])
  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null)
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [generateTopic, setGenerateTopic] = useState('Tecnologia')

  useEffect(() => {
    fetchArticles()
  }, [])

  const fetchArticles = async () => {
    try {
      setLoading(true)
      const data = await getArticles()
      setArticles(Array.isArray(data) ? data : [])
      setError(null)
    } catch (err) {
      setError('Erro ao carregar artigos')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const handleArticleClick = async (article: Article) => {
    try {
      const fullArticle = await getArticleById(article.id)
      setSelectedArticle(fullArticle)
    } catch (err) {
      setError('Erro ao carregar artigo')
      console.error(err)
    }
  }

  const handleBackClick = () => {
    setSelectedArticle(null)
  }

  const handleGenerateArticle = async () => {
    try {
      setGenerating(true)
      setError(null)
      const newArticle = await generateArticle(generateTopic)
      setArticles([newArticle, ...articles])
      setGenerateTopic('Tecnologia')
    } catch (err) {
      setError('Erro ao gerar artigo')
      console.error(err)
    } finally {
      setGenerating(false)
    }
  }

  if (loading) {
    return <div className="container"><p className="loading">Carregando artigos...</p></div>
  }

  if (selectedArticle) {
    return (
      <div className="container">
        <button className="back-button" onClick={handleBackClick}>← Voltar</button>
        <article className="article-detail">
          <h1>{selectedArticle.title}</h1>
          <div className="article-meta">
            <p>{selectedArticle.description}</p>
          </div>
          <div className="article-content">
            {selectedArticle.content}
          </div>
        </article>
      </div>
    )
  }

  return (
    <div className="container">
      <header className="header">
        <h1>Artigos</h1>
        <p className="subtitle">Explore nossos artigos mais recentes</p>
        
        <div className="generate-section">
          <input
            type="text"
            value={generateTopic}
            onChange={(e) => setGenerateTopic(e.target.value)}
            placeholder="Digite um tópico (ex: Python, DevOps...)"
            className="generate-input"
            disabled={generating}
          />
          <button
            onClick={handleGenerateArticle}
            disabled={generating || !generateTopic.trim()}
            className="generate-button"
          >
            {generating ? '⏳ Gerando...' : '🤖 Gerar Artigo'}
          </button>
        </div>
      </header>

      {error && <div className="error-message">{error}</div>}

      {articles.length === 0 ? (
        <p className="no-articles">Nenhum artigo encontrado</p>
      ) : (
        <div className="articles-grid">
          {articles.map((article) => (
            <button
              key={article.id}
              className="article-card"
              onClick={() => handleArticleClick(article)}
            >
              <h2>{article.title}</h2>
              <p className="article-description">{article.description || 'Sem descrição'}</p>
              <span className="read-more">Ler mais →</span>
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

export default App
