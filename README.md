# 📰 Blog Automático com IA

Sistema completo de blog com geração automática de artigos usando APIs gratuitas de IA.

## 🚀 Features

- ✅ **Backend** - API REST com Express.js
- ✅ **Frontend** - React + TypeScript + Vite
- ✅ **Geração de Artigos com IA** - Múltiplas opções gratuitas
- ✅ **Docker Compose** - Setup completo em um comando
- ✅ **Sem banco de dados** - Armazenamento em memória (fácil de adicionar BD)

## 🛠️ Tecnologias

### Backend
- Node.js + Express
- Axios (substituído por Fetch no frontend)
- node-cron (agendamento)
- Hugging Face API / JSONPlaceholder / Fallback

### Frontend
- React 18
- TypeScript
- Vite
- CSS moderno

## 🐳 Quick Start com Docker

### 1. Iniciar tudo com Docker Compose

```bash
docker-compose up --build
```

Acesse:
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3001/api/articles
- **Health Check**: http://localhost:3001/api/health

### 2. Parar containers

```bash
docker-compose down
```

### 3. Ver logs

```bash
# Todos os serviços
docker-compose logs -f

# Apenas backend
docker-compose logs -f backend

# Apenas frontend
docker-compose logs -f frontend
```

## 💻 Desenvolvimento Local (sem Docker)

### Backend

```bash
cd backend
npm install
npm run dev
```

Servidor em `http://localhost:3001`

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Aplicação em `http://localhost:5173`

## 🔧 Configuração

### Variáveis de Ambiente (Opcional)

Criar `.env` na raiz:

```env
# Hugging Face API (opcional)
HUGGINGFACE_API_KEY=hf_xxxxxxxxxxxxx
```

Para obter chave gratuita:
1. Ir em https://huggingface.co/settings/tokens
2. Criar novo token (acesso de leitura)
3. Adicionar ao `.env`

## 📡 API Endpoints

### GET /api/articles
Lista todos os artigos
```bash
curl http://localhost:3001/api/articles
```

### GET /api/articles/:id
Detalhes de um artigo
```bash
curl http://localhost:3001/api/articles/1
```

### POST /api/articles/generate
Gera novo artigo
```bash
curl -X POST http://localhost:3001/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"topic": "Docker", "style": "informative"}'
```

### DELETE /api/articles/:id
Deleta artigo
```bash
curl -X DELETE http://localhost:3001/api/articles/1
```

## 🎨 Interface do Frontend

- **Página Principal**: Grid de artigos com cards bonitos
- **Detalhes**: Clique em qualquer artigo para ver conteúdo completo
- **Responsivo**: Funciona em desktop, tablet e mobile
- **Estados**: Loading, erro, vazio

## 🤖 Opções de IA

### 1. Hugging Face (Recomendado)
- Modelos avançados de linguagem
- Requer: `HUGGINGFACE_API_KEY`
- Limite: ~30 req/min

### 2. JSONPlaceholder
- API pública para testes
- Sem autenticação
- Mock data realista

### 3. Fallback Local
- Gerador de artigos local
- Sempre disponível
- Sem dependências externas

## 📁 Estrutura do Projeto

```
assimetria/
├── backend/
│   ├── src/
│   │   ├── index.js           # Servidor Express
│   │   ├── routes/
│   │   │   └── articles.js    # Rotas da API
│   │   └── services/
│   │       ├── aiClient.js    # Cliente de IA
│   │       └── articleJob.js  # Agendamento
│   ├── Dockerfile
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── App.tsx            # Componente principal
│   │   ├── App.css            # Estilos
│   │   └── api/
│   │       └── articles.tsx   # Cliente API
│   ├── Dockerfile
│   └── package.json
├── docker-compose.yml
└── README.md
```

## 🔍 Troubleshooting

### Containers não iniciam
```bash
docker-compose down -v
docker-compose up --build
```

### Frontend não conecta ao backend
- Verificar se backend está rodando: http://localhost:3001/api/health
- Verificar CORS no backend
- Verificar porta 3001 disponível

### Artigos não aparecem
- Backend gera 5 artigos na primeira requisição
- Esperar ~10 segundos no primeiro acesso
- Ver logs: `docker-compose logs backend`

### Hot reload não funciona no Docker
- Configurado com `usePolling: true` no Vite
- Volumes montados corretamente

## 🚀 Próximos Passos

- [ ] Adicionar PostgreSQL/MongoDB
- [ ] Sistema de autenticação
- [ ] Comentários nos artigos
- [ ] Upload de imagens
- [ ] SEO otimizado
- [ ] Paginação
- [ ] Busca de artigos
- [ ] Tags e categorias

## 📝 Scripts Úteis

```bash
# Build para produção
docker-compose -f docker-compose.prod.yml up --build

# Rebuild apenas um serviço
docker-compose up --build backend

# Remover tudo (containers, volumes, redes)
docker-compose down -v --remove-orphans

# Entrar no container
docker exec -it blog-backend sh
```

## 📄 Licença

MIT

## 👤 Autor

Projeto de teste - Entrevista Assimetria
