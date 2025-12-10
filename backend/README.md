# Backend - Geração de Artigos com IA

Sistema backend que gera artigos automaticamente usando APIs gratuitas de IA.

## 🚀 Features

- ✅ Geração de artigos com múltiplas APIs gratuitas
- ✅ Fallback automático se uma API falhar
- ✅ Agendamento de geração de artigos (cron jobs)
- ✅ API REST para gerenciar artigos
- ✅ Sem dependências de APIs pagas

## 📋 Opções de IA Disponíveis

### 1. **Hugging Face** (Recomendado)
- Modelos avançados e gratuitos
- Requer: `HUGGINGFACE_API_KEY`
- [Obter token gratuito aqui](https://huggingface.co/settings/tokens)

### 2. **JSONPlaceholder** (Para testes)
- API pública sem autenticação
- Gera dados realistas (mock)

### 3. **Fallback** (Sempre disponível)
- Gerador local de artigos
- Não requer API externa
- Usado automaticamente como fallback

## 🛠️ Instalação

1. **Instalar dependências:**
```bash
npm install
```

2. **Configurar variáveis de ambiente:**
```bash
cp .env.example .env
# Editar .env e adicionar HUGGINGFACE_API_KEY (opcional)
```

3. **Iniciar servidor:**
```bash
# Modo desenvolvimento (com nodemon)
npm run dev

# Modo produção
npm start
```

O servidor estará disponível em `http://localhost:3001`

## 📡 API Endpoints

### GET /api/articles
Retorna todos os artigos

```bash
curl http://localhost:3001/api/articles
```

### GET /api/articles/:id
Retorna um artigo específico

```bash
curl http://localhost:3001/api/articles/1
```

### POST /api/articles/generate
Gera um novo artigo

```bash
curl -X POST http://localhost:3001/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"topic": "Python", "style": "informative"}'
```

### DELETE /api/articles/:id
Deleta um artigo

```bash
curl -X DELETE http://localhost:3001/api/articles/1
```

### GET /api/health
Verifica status do servidor

```bash
curl http://localhost:3001/api/health
```

## 🤖 Exemplo de Uso

### JavaScript/Node.js
```javascript
const response = await fetch('http://localhost:3001/api/articles');
const articles = await response.json();
console.log(articles);
```

### Python
```python
import requests
response = requests.get('http://localhost:3001/api/articles')
articles = response.json()
print(articles)
```

## 🔧 Configuração Avançada

### Usar Hugging Face
1. Ir em https://huggingface.co/settings/tokens
2. Criar novo token (ler acesso)
3. Adicionar ao `.env`:
```
HUGGINGFACE_API_KEY=hf_xxxxxxxxxxxxx
```

### Agendar Geração Automática
Editar `services/articleJob.js`:
```javascript
// Gerar artigos todo dia às 2 AM
scheduleArticleGeneration(db, '0 2 * * *');
```

### Conectar Banco de Dados
Adicionar em `index.js`:
```javascript
const db = require('./config/database');
scheduleArticleGeneration(db);
```

## 📝 Estrutura do Artigo

```json
{
  "id": "1",
  "title": "Inteligência Artificial: Guia Completo",
  "description": "Uma visão geral sobre IA...",
  "content": "Conteúdo completo do artigo...",
  "tags": ["inteligência artificial", "educação", "tutorial"],
  "status": "published",
  "views": 42,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

## ⚠️ Limitações & Rate Limits

- **Hugging Face**: ~30 requisições/minuto (free)
- **JSONPlaceholder**: ~60 requisições/minuto
- Fallback local: Sem limite

## 🐛 Troubleshooting

**Erro: "HUGGINGFACE_API_KEY not configured"**
- Solução: Deixe em branco ou remova se quiser usar fallback

**Erro: "Invalid response format"**
- Solução: API pode estar sobrecarregada, use fallback

**Artigos não aparecem no frontend**
- Verificar se backend está rodando: `http://localhost:3001/api/health`
- Verificar CORS configurado em `index.js`

## 📚 Referências

- [Hugging Face Inference API](https://huggingface.co/docs/api-inference)
- [JSONPlaceholder](https://jsonplaceholder.typicode.com/)
- [node-cron](https://www.npmjs.com/package/node-cron)

## 📄 Licença

MIT
