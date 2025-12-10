# 📰 AI Blog

Automatic blog system that generates articles using artificial intelligence. Built with React, Express.js, PostgreSQL, and Docker.

## ✨ Features

- **AI-Powered Content** - DeepSeek-V3.2 via Hugging Face API
- **Full Stack** - React 19 + TypeScript + Express.js + PostgreSQL
- **Docker Ready** - Complete setup with Docker Compose
- **Responsive UI** - Modern design for all devices
- **REST API** - Complete CRUD operations for articles
- **Production Ready** - AWS EC2 deployment included

## 🚀 Quick Start

### With Docker (Recommended)

```bash
# Start all services
docker-compose up

# Access the app
# Frontend: http://localhost:5173
# Backend API: http://localhost:3001/api/articles
# Health Check: http://localhost:3001/api/health
```

### Without Docker

**Backend:**
```bash
cd backend
npm install
npm run dev      # Runs on port 3001
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev      # Runs on port 5173
```

## 🔌 Tech Stack

| Layer | Technologies |
|-------|--------------|
| **Frontend** | React 19, TypeScript 5.9, Vite 7.2, Fetch API |
| **Backend** | Node.js 20, Express 4.18, PostgreSQL 15 |
| **AI** | Hugging Face API (DeepSeek-V3.2) |
| **DevOps** | Docker, Docker Compose, AWS EC2 |

## 📡 API Endpoints

```bash
GET    /api/articles              # List all articles
GET    /api/articles/:id          # Get specific article
POST   /api/articles/generate     # Generate new article with AI
DELETE /api/articles/:id          # Delete article
GET    /api/health                # Health check
```

**Example - Generate Article:**
```bash
curl -X POST http://localhost:3001/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"title": "AI Trends", "topic": "technology"}'
```

## 🔧 Configuration

### Environment Variables (Local)

Create `.env` in project root:
```bash
# Database
DB_USER=user
DB_PASSWORD=password
DB_NAME=blog
DB_HOST=postgres

# AI
HF_TOKEN=hf_your_huggingface_token

# API
PORT=3001
NODE_ENV=development
VITE_API_URL=http://localhost:3001/api
```

Get free Hugging Face token: https://huggingface.co/settings/tokens

### Production (AWS EC2)

See [ARCHITECTURE.md](./docs/ARCHITECTURE.md#production-environment-aws-ec2) for complete deployment guide.

```bash
# SSH to EC2 instance
ssh -i key.pem ec2-user@your-ip

# Clone repo and deploy
git clone https://github.com/your-user/your-repo.git
cd your-repo
chmod +x infra/scripts/init-ec2.sh
./infra/scripts/init-ec2.sh  # Setup (once)
./infra/scripts/deploy.sh    # Deploy app
```

## 📁 Project Structure

```
assimetria/
├── frontend/              # React + TypeScript
│   ├── src/
│   │   ├── App.tsx       # Main component
│   │   ├── api/          # API client (Fetch)
│   │   └── App.css       # Styles
│   └── package.json
├── backend/              # Express.js API
│   ├── src/
│   │   ├── index.js      # Server
│   │   ├── routes/       # API routes
│   │   └── services/     # Business logic
│   └── package.json
├── infra/               # Deployment scripts
│   └── scripts/
│       ├── init-ec2.sh  # EC2 setup
│       └── deploy.sh    # App deployment
├── docs/
│   └── ARCHITECTURE.md  # Full architecture guide
└── docker-compose.yml   # Local dev orchestration
```

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Disk full** | `docker system prune -a -f` |
| **Cached images** | `docker-compose pull && docker-compose up --force-recreate` |
| **Frontend can't reach backend** | Check `VITE_API_URL` in `.env` or environment |
| **Database connection fails** | Verify `DB_HOST`, password, and postgres_data volume exists |
| **AI not generating articles** | Check `HF_TOKEN` is valid and has internet connectivity |

## 📚 Documentation

- **[ARCHITECTURE.md](./docs/ARCHITECTURE.md)** - Complete system design and deployment guide
- **[infra/scripts/init-ec2.sh](./infra/scripts/init-ec2.sh)** - EC2 instance initialization
- **[infra/scripts/deploy.sh](./infra/scripts/deploy.sh)** - Application deployment automation

## 🛠️ Useful Commands

```bash
# View logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Rebuild services
docker-compose up --build

# Clean up everything
docker-compose down -v --remove-orphans

# Access backend container
docker exec -it blog-backend sh

# Check health
curl http://localhost:3001/api/health
```

## 🚀 Deployment Options

1. **Docker Compose (Current)** - Simple, all-in-one
2. **AWS EC2** - Production deployment with bash scripts

## 📄 License

MIT

## 👤 Author

José Marques @ Assimetria Interview Project - December 2025

