# 📐 Architecture - AI Blog

## Overview

Dynamic blog that automatically generates articles using artificial intelligence. Modern architecture with Docker Compose for easy deployment.

```
┌─────────────┐          ┌──────────────┐          ┌──────────────┐
│  Frontend   │◄─────────┤   Backend    │◄─────────┤   Database   │
│  (React)    │          │  (Express)   │          │ (PostgreSQL) │
└─────────────┘          └──────────────┘          └──────────────┘
    :5173                     :3001                      :5432
    Vite                      Node.js 20                 PostgreSQL 15
    TypeScript                ES Modules                 Alpine
```

---

## 🏗️ Project Structure

```
assimetria/
├── frontend/                 # React + TypeScript Application
│   ├── src/
│   │   ├── App.tsx          # Main component
│   │   ├── main.tsx         # Entry point
│   │   ├── api/
│   │   │   └── articles.tsx # API client (Fetch)
│   │   ├── App.css          # Styles
│   │   └── index.css
│   ├── vite.config.ts       # Vite build config
│   ├── tsconfig.json        # TypeScript config
│   └── package.json
│
├── backend/                  # Node.js + Express API
│   ├── src/
│   │   ├── index.js         # Express server
│   │   ├── config/
│   │   │   └── database.js  # PostgreSQL connection
│   │   ├── models/          # Data models
│   │   ├── routes/          # API routes
│   │   │   └── articles.js  # GET/POST/DELETE articles
│   │   └── services/        # Business logic
│   │       ├── aiClient.js  # Hugging Face integration
│   │       └── articleJob.js # Article generation job
│   ├── Dockerfile           # Dev build
│   ├── Dockerfile.prod      # Prod build
│   └── package.json
│
├── infra/                    # Deployment configuration
│   ├── scripts/
│   │   ├── init-ec2.sh      # EC2 setup (Docker, Docker Compose, Git)
│   │   └── deploy.sh        # App deployment (git pull, docker-compose up)
│   ├── buildspec.yml        # AWS CodeBuild config
│   └── docker-compose.yml   # Prod compose
│
├── docs/
│   ├── ARCHITECTURE.md      # This file
│   └── README.md
│
└── docker-compose.yml       # Local dev
```

---

## 🔌 Technology Stack

### Frontend
| Technology | Version | Purpose |
|-----------|---------|---------|
| **React** | 19.2 | UI Framework |
| **TypeScript** | 5.9 | Type-safe JavaScript |
| **Vite** | 7.2 | Fast build tool |
| **Fetch API** | Native | HTTP requests |

### Backend
| Technology | Version | Purpose |
|-----------|---------|---------|
| **Node.js** | 20 | JavaScript Runtime |
| **Express** | 4.18 | Web Framework |
| **PostgreSQL** | 15 Alpine | Relational Database |
| **@huggingface/inference** | 2.8 | AI Client (DeepSeek-V3.2) |
| **node-cron** | 3.0 | Task scheduling |
| **CORS** | 2.8 | Request origin control |

### DevOps
| Technology | Purpose |
|-----------|---------|
| **Docker** | Containerization |
| **Docker Compose** | Local + production orchestration |
| **AWS EC2** | Compute server |
| **AWS ECR** | Container registry |
| **Bash Scripts** | Deployment automation |

---

## 📡 API Endpoints

### Articles
```
GET    /api/articles              # List all articles
GET    /api/articles/:id          # Get specific article
POST   /api/articles/generate     # Generate new article with AI
DELETE /api/articles/:id          # Delete article
GET    /api/health                # Health check
```

### Request/Response

**POST /api/articles/generate**
```json
{
  "title": "Artificial Intelligence in 2025",
  "topic": "AI trends"
}
```

**Response**
```json
{
  "id": 1,
  "title": "Artificial Intelligence in 2025",
  "content": "...",
  "createdAt": "2025-12-10T10:30:00Z"
}
```

---

## 🗄️ Database

### PostgreSQL Schema

```sql
CREATE TABLE articles (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  topic VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_topic (topic),
  INDEX idx_created (created_at)
);
```

**Auto-initialization:** Database starts empty, schema created automatically on first start.

---

## 🚀 Deployment

### Local Environment (Dev)

```bash
docker-compose up
```

**Services:**
- Frontend: http://localhost:5173 (Vite dev server)
- Backend: http://localhost:3001
- Database: postgres://user:password@localhost:5432/blog

### Production Environment (AWS EC2)

**EC2 Setup (once):**
```bash
ssh -i key.pem ec2-user@your-ip
git clone https://github.com/your-user/your-repo.git
cd your-repo
chmod +x infra/scripts/init-ec2.sh
./infra/scripts/init-ec2.sh  # Installs Docker, Docker Compose, Git
```

**Deploy Application:**
```bash
./infra/scripts/deploy.sh
# Automatic script:
# 1. Git pull (updates code)
# 2. Prompt for environment variables
# 3. docker-compose pull (pull images)
# 4. docker-compose up (start services)
# 5. Health checks
```

**Required Environment Variables:**
```bash
DB_USER=user
DB_PASSWORD=your-password
DB_NAME=blog
HF_TOKEN=hf_your-token     # Hugging Face API key
FRONTEND_URL=http://your-ip
VITE_API_URL=http://your-ip:3001/api
```

---

## 🤖 AI Integration

### Primary Model: DeepSeek-V3.2
- **Provider:** Hugging Face Router
- **Encoding:** UTF-8 with TextEncoder
- **Max tokens:** 1024
- **Fallback:** Local models if API fails

### Article Generation Flow
```
1. User requests article → POST /api/articles/generate
2. Backend calls aiClient.js
3. DeepSeek generates content via Hugging Face API
4. Content saved to PostgreSQL
5. Response returns to frontend
6. Frontend renders article
```

---

## 🐳 Docker Compose

### Development (`docker-compose.yml`)

3 orchestrated services:
- **PostgreSQL:** Persistent volume, healthcheck
- **Backend:** Local build, hot-reload (nodemon), bind volumes
- **Frontend:** Local build, Vite dev server, bind volumes

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    # Variables from local .env
  backend:
    build: ./backend
    command: npm run dev     # nodemon auto-reload
  frontend:
    build: ./frontend
    command: npm run dev     # Vite dev server
```

### Production (`docker-compose.prod.yml`)

3 services with ECR images:
- Uses pre-built images (no local build)
- No bind volumes (no source code in production)
- Restart policies
- More aggressive healthchecks

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
  backend:
    image: 904027687032.dkr.ecr.eu-north-1.amazonaws.com/autoblog/backend:latest
    restart: unless-stopped
  frontend:
    image: 904027687032.dkr.ecr.eu-north-1.amazonaws.com/autoblog/frontend:latest
    restart: unless-stopped
```

---

## ⚙️ Environment Variables

### Local (`.env`)
```bash
# Database
DB_USER=user
DB_PASSWORD=password
DB_NAME=blog
DB_HOST=postgres           # Docker Compose DNS

# AI
HF_TOKEN=hf_your_token

# API
PORT=3001
VITE_API_URL=http://localhost:3001/api
NODE_ENV=development
```

### Production (AWS EC2)
```bash
# Define in docker-compose.prod.yml or via deploy.sh prompt
DB_USER=user
DB_PASSWORD=your-secure-password
HF_TOKEN=hf_your_token
FRONTEND_URL=http://your-ec2-ip
VITE_API_URL=http://your-ec2-ip:3001/api
```

---

## 🔄 Main Flows

### 1. List Articles
```
Frontend (React)
    ↓ GET /api/articles
Backend (Express)
    ↓ SELECT * FROM articles
PostgreSQL
    ↓ JSON response
Frontend renders list
```

### 2. Generate Article with AI
```
Frontend
    ↓ POST /api/articles/generate
Backend
    ↓ aiClient.generateContent()
Hugging Face API (DeepSeek-V3.2)
    ↓ Content generated
Backend
    ↓ INSERT INTO articles
PostgreSQL
    ↓ JSON response
Frontend renders new article
```

### 3. Deploy to AWS
```
Git commit/push
    ↓ SSH to EC2
    ↓ ./deploy.sh
Git pull (code updated)
    ↓ docker-compose pull (new images)
    ↓ docker-compose up --force-recreate
Containers restarted with new code
    ↓ Health checks
Application available
```

---

## 🛡️ Security

| Aspect | Implementation |
|--------|----------------|
| **CORS** | Restricted to FRONTEND_URL in production |
| **API Keys** | HF_TOKEN via environment variables (not hardcoded) |
| **Database** | PostgreSQL authentication with credentials |
| **Port Binding** | Frontend port 80 (HTTP), Backend :3001 |
| **Docker Volumes** | Data persists in postgres_data volume |

---

## 📊 Healthchecks

Each service has a healthcheck:

**Backend:**
```bash
GET http://localhost:3001/api/health
Response: { "status": "ok", "timestamp": "..." }
```

**PostgreSQL:**
```bash
pg_isready -U user
```

Docker Compose waits for healthchecks before starting dependencies.

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Docker disk full | `docker system prune -a -f` |
| Cached images | `docker-compose pull && docker-compose up --force-recreate` |
| Port 3001 in use | `lsof -i :3001` and kill process |
| Frontend can't see Backend | Check VITE_API_URL in .env |
| PostgreSQL connection fails | Check DB_HOST, password, postgres_data volume |
| AI not generating articles | Check HF_TOKEN, internet connectivity |

---

**Last updated:** December 2025
**Version:** 1.0 Production
