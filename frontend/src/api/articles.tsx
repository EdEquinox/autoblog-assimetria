const API_BASE_URL = 'http://13.62.230.242:3001/api';

export const getArticles = async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/articles`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  } catch (error) {
    console.error('Error fetching articles:', error);
    throw error;
  }
};

export const getArticleById = async (id: string) => {
  try {
    const response = await fetch(`${API_BASE_URL}/articles/${id}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  } catch (error) {
    console.error('Error fetching article:', error);
    throw error;
  }
};

export const generateArticle = async (topic: string = 'Tecnologia', style: string = 'informative') => {
  try {
    const response = await fetch(`${API_BASE_URL}/articles/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ topic, style })
    });
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  } catch (error) {
    console.error('Error generating article:', error);
    throw error;
  }
};
