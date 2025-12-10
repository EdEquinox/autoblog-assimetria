# 📚 Guia de Deploy para AWS

## Problemas Corrigidos

✅ **URL Hardcoded** - Agora usa variáveis de ambiente `VITE_API_URL`  
✅ **CORS Restritivo** - Configurado dinamicamente via `FRONTEND_URL`  
✅ **Nginx Config** - Melhorado para melhor proxy e timeout handling  
✅ **Build Args** - Frontend Dockerfile agora aceita `VITE_API_URL`

---

## 1. Preparação do Ambiente AWS

### 1.1 Configurar Variáveis de Ambiente

Crie um arquivo `.env.prod` com:

```bash
# Database (use RDS if available)
DB_HOST=your-rds-endpoint.amazonaws.com
DB_PORT=5432
DB_NAME=blog
DB_USER=admin
DB_PASSWORD=your-secure-password

# AI Services
HF_TOKEN=your_hugging_face_token

# Frontend & Backend URLs
# Para AWS EC2 ou ECS, use o IP/DNS público
VITE_API_URL=http://your-backend-ip:3001/api
FRONTEND_URL=http://your-frontend-domain.com

# Environment
NODE_ENV=production
PORT=3001
```

---

## 2. Deploy com Docker Compose no AWS EC2

### 2.1 Build e Deploy

```bash
# SSH na instância AWS
ssh -i your-key.pem ec2-user@your-instance-ip

# Clone do repositório
git clone your-repo.git
cd assimetria

# Carregar variáveis de ambiente
source .env.prod

# Build e iniciar
docker-compose -f docker-compose.prod.yml up -d

# Verificar logs
docker-compose logs -f backend
docker-compose logs -f frontend
```

### 2.2 Endereços Importantes

- **Frontend**: `http://your-instance-ip`
- **Backend API**: `http://your-instance-ip:3001/api`
- **Health Check**: `http://your-instance-ip:3001/api/health`

---

## 3. Configuração de Security Groups

Abra estas portas no AWS Security Group:

```
Port 80   (HTTP) - Frontend
Port 443  (HTTPS) - Recomendado com SSL
Port 3001 (Backend) - Apenas se precisar acesso direto
Port 5432 (PostgreSQL) - Apenas se usar EC2 local (use RDS em produção)
```

---

## 4. Frontend Configuration

O frontend agora:
- ✅ Lê `VITE_API_URL` da variável de ambiente
- ✅ Usa `/api` como fallback (funciona com nginx proxy)
- ✅ Logueia qual URL está usando em `console.log`

### 4.1 Teste Local (Verificar)

```bash
# Development (usa localhost)
npm run dev

# Build com variável de ambiente
VITE_API_URL=http://api.example.com npm run build

# Preview (verifica build)
npm run preview
```

---

## 5. Backend Configuration

### 5.1 CORS Automático

O backend agora configura CORS baseado em:

```javascript
// Se NODE_ENV=production
origin: process.env.FRONTEND_URL || '*'

// Se NODE_ENV=development
origin: '*'
```

**Importante**: Em produção, defina `FRONTEND_URL` para restringir CORS

### 5.2 Exemplo de Logs Esperados

```
✓ PostgreSQL connected
✓ Database schema initialized
Backend server running on http://0.0.0.0:3001
CORS configured for origin: http://your-frontend-domain.com
API: http://0.0.0.0:3001/api/articles
```

---

## 6. Troubleshooting

### 6.1 "Failed to fetch articles"

**Causa**: Frontend não consegue conectar ao backend

**Solução**:
```bash
# 1. Verificar se VITE_API_URL está correto
docker exec blog-frontend-prod env | grep VITE_API_URL

# 2. Verificar conectividade
curl http://backend:3001/api/health

# 3. Verificar logs do backend
docker-compose logs backend
```

### 6.2 "CORS error"

**Causa**: `FRONTEND_URL` não está configurado corretamente

**Solução**:
```bash
# Atualizar .env.prod
FRONTEND_URL=http://seu-dominio-real.com

# Reiniciar backend
docker-compose restart backend

# Verificar logs
docker-compose logs backend | grep CORS
```

### 6.3 "API endpoint not found"

**Causa**: Nginx não está fazendo proxy corretamente

**Solução**:
```bash
# Verificar nginx config
docker exec blog-frontend-prod nginx -t

# Verificar proxy funciona
curl -v http://localhost/api/health

# Ver logs do nginx
docker logs blog-frontend-prod
```

---

## 7. Monitoramento

### 7.1 Health Checks

```bash
# Frontend
curl http://your-instance-ip

# Backend
curl http://your-instance-ip:3001/api/health

# Database
docker exec blog-postgres pg_isready -U user
```

### 7.2 Ver Logs em Tempo Real

```bash
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend
```

---

## 8. SSL/HTTPS (Recomendado para Produção)

Para usar HTTPS, considere:

1. **AWS ALB (Application Load Balancer)**
   - Gerencia SSL automaticamente
   - Melhor para escalabilidade

2. **Let's Encrypt + Nginx**
   ```bash
   # Instalar Certbot
   docker run -it --rm \
     -v /etc/letsencrypt:/etc/letsencrypt \
     certbot/certbot certonly --standalone \
     -d seu-dominio.com
   ```

3. **ACM (AWS Certificate Manager)**
   - Integração nativa com ALB/CloudFront

---

## 9. Checklist Final

- [ ] Variáveis de ambiente carregadas (`.env.prod`)
- [ ] Database configurado (RDS ou local)
- [ ] Backend container saudável (`docker-compose ps`)
- [ ] Frontend acessível em HTTP
- [ ] API funcionando (`/api/articles`)
- [ ] Articles sendo gerados com DeepSeek
- [ ] Logs monitorados e sem erros
- [ ] Security Groups abertos corretamente
- [ ] CORS configurado para seu domínio

---

## Dúvidas Comuns

**P: O frontend não vê o backend**  
R: Verifique `VITE_API_URL` e reinicie o build (`docker-compose restart frontend`)

**P: CORS error mesmo com configuração**  
R: Limpe cache do navegador e verifique `FRONTEND_URL` no backend

**P: Artigos não são gerados**  
R: Verifique `HF_TOKEN` e logs do DeepSeek no backend

---

Boa sorte com o deploy! 🚀
