# 🔧 Mudanças para Fix AWS Deployment

## Resumo dos Problemas Corrigidos

### ❌ Antes
- Frontend tinha URL hardcoded: `http://13.62.230.242:3001/api`
- CORS sem configuração dinâmica
- Nginx com timeout insuficiente
- Sem variáveis de ambiente para diferentes ambientes

### ✅ Depois
- Frontend lê `VITE_API_URL` da variável de ambiente
- CORS configurado dinamicamente via `FRONTEND_URL`
- Nginx otimizado com timeouts, buffering e headers
- Suporte completo para dev, staging e production

---

## Arquivos Modificados

### 1. **frontend/src/api/articles.tsx**
```javascript
// ❌ Antes
const API_BASE_URL = 'http://13.62.230.242:3001/api';

// ✅ Depois
const API_BASE_URL = import.meta.env.VITE_API_URL || '/api';
console.log('Using API_BASE_URL:', API_BASE_URL);
```

### 2. **frontend/vite.config.ts**
- Adicionado `define` para passar variáveis de ambiente durante build
- Configurado `outDir` e `sourcemap`

### 3. **frontend/Dockerfile.prod**
```dockerfile
# ✅ Novo
ARG VITE_API_URL=/api
ENV VITE_API_URL=${VITE_API_URL}
```

### 4. **frontend/nginx.conf**
```nginx
# ✅ Melhorias
- Adicionado X-Real-IP e X-Forwarded-For headers
- Aumentado timeout: 60s (antes: indefinido/default)
- Configurado buffering para respostas grandes
- Adicionado security headers
```

### 5. **backend/src/index.js**
```javascript
// ✅ Novo CORS dinâmico
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.FRONTEND_URL || '*'
    : '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};
app.use(cors(corsOptions));
```

### 6. **docker-compose.prod.yml**
```yaml
# ✅ Backend
environment:
  - FRONTEND_URL=${FRONTEND_URL:-http://localhost}
  - HF_TOKEN=${HF_TOKEN:-}
  - DB_HOST=${DB_HOST:-postgres}
  # ... outras variáveis

# ✅ Frontend
build:
  args:
    - VITE_API_URL=${VITE_API_URL:-http://backend:3001/api}
environment:
  - VITE_API_URL=${VITE_API_URL:-http://backend:3001/api}
```

---

## Arquivos Novos

### 1. **.env.example**
Documento referência com todas as variáveis de ambiente

### 2. **AWS_DEPLOYMENT.md**
Guia completo para deploy em AWS:
- Configuração de variáveis
- Deploy em EC2
- Security Groups
- Troubleshooting
- Monitoramento

### 3. **test-api-communication.sh**
Script para testar comunicação frontend-backend:
```bash
bash test-api-communication.sh
```

Verifica:
- ✅ Backend online
- ✅ Frontend/Nginx proxy
- ✅ PostgreSQL
- ✅ CORS configurado
- ✅ Variáveis de ambiente
- ✅ Geração de artigos

---

## Como Usar Para Deploy AWS

### 1. Preparar Variáveis
```bash
cat > .env.prod << EOF
VITE_API_URL=http://seu-backend-ip:3001/api
FRONTEND_URL=http://seu-frontend-url
HF_TOKEN=seu-token-aqui
DB_HOST=seu-rds-host
DB_PASSWORD=senha-forte
NODE_ENV=production
EOF
```

### 2. Deploy
```bash
# Carregar variáveis
source .env.prod

# Build e iniciar
docker-compose -f docker-compose.prod.yml up -d

# Verificar
bash test-api-communication.sh
```

### 3. Acessar
- Frontend: `http://seu-ec2-ip`
- Backend API: `http://seu-ec2-ip:3001/api`
- Health: `http://seu-ec2-ip:3001/api/health`

---

## Variáveis de Ambiente Necessárias

| Variável | Uso | Exemplo |
|----------|-----|---------|
| `VITE_API_URL` | URL do backend (frontend) | `http://backend:3001/api` |
| `FRONTEND_URL` | URL do frontend (CORS) | `http://localhost:5173` |
| `HF_TOKEN` | Token Hugging Face | `hf_xxxxx...` |
| `DB_HOST` | Host do banco | `localhost` ou RDS endpoint |
| `DB_PASSWORD` | Senha do banco | Senha segura |
| `NODE_ENV` | Ambiente | `development` ou `production` |

---

## Testes Recomendados

```bash
# 1. Verificar que frontend consegue chamar backend
curl -v http://localhost/api/health

# 2. Testar geração de artigos
curl -X POST http://localhost/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"topic":"Test","style":"informative"}'

# 3. Ver logs em tempo real
docker-compose logs -f backend

# 4. Verificar variáveis no container
docker exec blog-backend-prod env | grep FRONTEND
docker exec blog-frontend-prod env | grep VITE_API
```

---

## Diferenças de Configuração

### Local Development
```
VITE_API_URL=http://localhost:3001/api
FRONTEND_URL=http://localhost:5173
NODE_ENV=development
```

### Docker Compose (local com containers)
```
VITE_API_URL=http://backend:3001/api
FRONTEND_URL=http://localhost
NODE_ENV=development
```

### AWS EC2 Production
```
VITE_API_URL=http://seu-ec2-ip:3001/api
FRONTEND_URL=http://seu-ec2-ip
NODE_ENV=production
```

### AWS com Load Balancer
```
VITE_API_URL=https://api.seu-dominio.com
FRONTEND_URL=https://seu-dominio.com
NODE_ENV=production
```

---

## Checklist Final

- [ ] `.env.prod` criado com valores corretos
- [ ] `docker-compose.prod.yml` pronto
- [ ] Security Groups abertos (80, 443, 3001)
- [ ] `bash test-api-communication.sh` passou
- [ ] Frontend carrega artigos
- [ ] Geração de artigos funciona
- [ ] Logs sem erros
- [ ] CORS funcionando (sem console errors)
- [ ] Health endpoint respondendo

---

✅ **Tudo pronto para AWS!**
