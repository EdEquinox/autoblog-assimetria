// aiClient.js
/**
 * Generates article content using Hugging Face Router
 * Uses DeepSeek-V3.2 via direct fetch to router.huggingface.co
 * Requires HF_TOKEN environment variable
 */

/**
 * Query the Hugging Face Router API with proper UTF-8 handling
 */
async function queryHfRouter(messages, model = 'deepseek-ai/DeepSeek-V3.2') {
  const token = process.env.HF_TOKEN;
  if (!token) {
    throw new Error('HF_TOKEN not configured');
  }

  try {
    console.log('Calling HF Router with model:', model);
    
    const response = await fetch(
      'https://router.huggingface.co/v1/chat/completions',
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: JSON.stringify({
          model,
          messages,
          max_tokens: 2000,
          temperature: 0.7,
        }),
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error('HF Router error:', response.status, errorText);
      
      if (response.status === 403) {
        throw new Error('Permission denied - token needs Inference permissions');
      }
      throw new Error(`API error ${response.status}: ${errorText}`);
    }

    const result = await response.json();
    console.log('HF Router response received successfully');
    return result;
  } catch (error) {
    console.error('HF Router call failed:', error.message);
    throw error;
  }
}

async function generateArticle(topic, style = 'informative') {
  try {
    // Try DeepSeek-V3.2 via Hugging Face Router
    const response = await generateWithHuggingFaceRouter(topic, style);
    
    return {
      title: generateTitle(topic),
      description: response.substring(0, 200),
      content: response,
      tags: extractTags(topic)
    };
  } catch (error) {
    console.error('AI generation failed, using fallback:', error.message);
    return generateFallbackArticle(topic);
  }
}

/**
 * Generate text using Hugging Face Router with DeepSeek model
 * Model: deepseek-ai/DeepSeek-V3.2
 */
async function generateWithHuggingFaceRouter(topic, style) {
  const prompt = `Write a ${style} article about "${topic}" in Portuguese. 
Make it informative and well-structured with at least 300 words.
Write in plain text without any markdown formatting (no **, no *, no #).`;

  try {
    console.log('Generating article with DeepSeek-V3.2...');
    
    const result = await queryHfRouter([
      {
        role: 'system',
        content: 'You are a helpful AI assistant that writes high-quality articles in Portuguese. Always write in plain text without markdown formatting.'
      },
      {
        role: 'user',
        content: prompt,
      }
    ]);

    console.log('DeepSeek response received');
    
    if (result.choices && result.choices[0] && result.choices[0].message) {
      const content = result.choices[0].message.content;
      // Remove any markdown formatting that might still appear
      return content
        .replaceAll('**', '')  // Remove bold markers
        .replaceAll('*', '')   // Remove italic markers  
        .replace(/#{1,6}\s/g, '') // Remove heading markers
        .trim();
    }
    throw new Error('Invalid response format from API');
  } catch (error) {
    console.error('DeepSeek generation error:', error.message);
    throw new Error(`DeepSeek generation failed: ${error.message}`);
  }
}

/**
 * Fallback article generator (no API required)
 * Used when Hugging Face Router is unavailable
 */
function generateFallbackArticle(topic) {
  const templates = [
    `${topic} é um tema fascinante e relevante nos dias de hoje. Neste artigo, exploraremos os principais aspectos que definem este conceito e sua importância.`,
    `Você já parou para pensar sobre ${topic}? Descubra como este tema impacta nossa sociedade e o que especialistas têm a dizer.`,
    `${topic} continua evoluindo. Conheça as tendências mais recentes, desafios e oportunidades nesta área em constante transformação.`
  ];

  const template = templates[Math.floor(Math.random() * templates.length)];
  const content = `${template}\n\n` +
    `A importância de ${topic} cresce a cada dia. Profissionais e entusiastas dedicam-se a compreender melhor este universo complexo.\n\n` +
    `Neste artigo, abordaremos:\n` +
    `• Definição e conceitos fundamentais\n` +
    `• Aplicações práticas\n` +
    `• Desafios atuais\n` +
    `• Perspectivas futuras\n\n` +
    `Esperamos que este conteúdo seja útil para sua jornada de aprendizado sobre ${topic}.`;

  return {
    title: generateTitle(topic),
    description: template.substring(0, 150),
    content: content,
    tags: extractTags(topic)
  };
}

function generateTitle(topic) {
  const prefixes = [
    `${topic}: Guia Completo`,
    `Tudo sobre ${topic}`,
    `${topic} Explicado`,
    `Entendendo ${topic}`,
    `${topic} em 2024`
  ];
  return prefixes[Math.floor(Math.random() * prefixes.length)];
}

function extractTags(topic) {
  return [
    topic.toLowerCase(),
    'educação',
    'tutorial',
    'insights'
  ];
}

export {
  generateArticle,
  generateWithHuggingFaceRouter,
  generateFallbackArticle
};
