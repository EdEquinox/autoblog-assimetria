# ✅ Checklist de Deploy AWS - Guia Passo a Passo

## Antes de Começar

- [ ] Ter uma instância EC2 no AWS
- [ ] Ter acesso SSH à instância (`ssh -i key.pem ec2-user@seu-ip`)
- [ ] Ter instalado Docker e Docker Compose na instância
- [ ] Ter o código do projeto clonado na instância

---

## Passo 1: Conectar ao AWS via SSH

```bash
ssh -i seu-key.pem ec2-user@seu-ec2-ip
```

Ou se for Ubuntu:
```bash
ssh -i seu-key.pem ubuntu@seu-ec2-ip
```

---

## Passo 2: Clonar o Repositório

```bash
git clone seu-repo-url
cd assimetria
```

---

## Passo 3: Criar Arquivo .env.prod

```bash
# Opção A: Manual (recomendado para produção)
cat > .env.prod << 'EOF'
NODE_ENV=production
PORT=3001

# Hugging Face - Get token at https://huggingface.co/settings/tokens
HF_TOKEN=hf_xxxxxxxxxxxxxxxx

# Frontend e CORS
VITE_API_URL=http://seu-ec2-ip:3001/api
FRONTEND_URL=http://seu-ec2-ip

# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=blog
DB_USER=user
DB_PASSWORD=sua-senha-forte-aqui-minimo-12-chars
EOF
```

**⚠️ IMPORTANTE**: 
- `HF_TOKEN`: Pegue em https://huggingface.co/settings/tokens
- `VITE_API_URL`: Use o IP público ou DNS da instância
- `FRONTEND_URL`: Mesma URL que acima
- `DB_PASSWORD`: Use uma senha FORTE (mínimo 12 caracteres)

---

## Passo 4: Verificar Arquivos Necessários

```bash
# Verificar que todos os arquivos existem
ls -la docker-compose.prod.yml
ls -la .env.prod
ls -la backend/Dockerfile.prod
ls -la frontend/Dockerfile.prod
```

Deve aparecer: ✅ (todos os 4 arquivos)

---

## Passo 5: Fazer Deploy

### Opção A: Usando Script Automático (Recomendado)

```bash
chmod +x deploy-aws.sh
./deploy-aws.sh
```

### Opção B: Manual

```bash
# 1. Carregar variáveis de ambiente
export $(cat .env.prod | xargs)

# 2. Build e iniciar containers
docker-compose -f docker-compose.prod.yml up -d --build

# 3. Verificar status
docker-compose -f docker-compose.prod.yml ps

# 4. Aguardar backend ficar pronto (2-3 minutos)
sleep 60
curl http://localhost:3001/api/health
```

---

## Passo 6: Verificar que Está Funcionando

```bash
# 1. Verificar containers rodando
docker-compose -f docker-compose.prod.yml ps

# Output esperado:
# NAME                    STATUS              PORTS
# blog-postgres-prod      Up                  5432/tcp
# blog-backend-prod       Up (healthy)        3001/tcp
# blog-frontend-prod      Up                  80/tcp
```

```bash
# 2. Verificar Health Check
curl http://localhost:3001/api/health
# Esperado: {"status":"ok","timestamp":"2025-12-10T..."}
```

```bash
# 3. Verificar que Frontend consegue acessar Backend
curl http://localhost/api/health
# Esperado: {"status":"ok","timestamp":"2025-12-10T..."}
```

```bash
# 4. Testar geração de artigo
curl -X POST http://localhost:3001/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"topic":"AI","style":"informative"}'
# Esperado: JSON com "title", "content", etc.
```

---

## Passo 7: Acessar a Aplicação

**Do seu navegador local:**

```
http://seu-ec2-ip
```

Deve ver:
- ✅ Lista de artigos (pode estar vazia inicialmente)
- ✅ Botão "Gerar Artigo"
- ✅ Artigos podem ser clicados para ver detalhe
- ✅ Sem erros no console do navegador

---

## Passo 8: Configurar Security Group

No AWS Console, ir para Security Group da instância:

### Adicionar estas regras de inbound:

| Type | Protocol | Port Range | Source |
|------|----------|-----------|--------|
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 (opcional) |
| Custom TCP | TCP | 3001 | 0.0.0.0/0 (apenas se precisar) |

**Importante**: PostgreSQL (5432) deve estar fechado para o exterior!

---

## Debugging - Se Algo Não Funcionar

### 1. Frontend Não Abre

```bash
# Verificar se Nginx está rodando
docker exec blog-frontend-prod nginx -t

# Ver logs do Nginx
docker logs blog-frontend-prod

# Tentar acessar diretamente
curl -v http://localhost/
```

### 2. "Failed to Fetch Articles"

```bash
# Verificar variável de ambiente no frontend
docker exec blog-frontend-prod env | grep VITE_API_URL

# Verificar conectividade do container
docker exec blog-frontend-prod curl http://backend:3001/api/articles

# Ver logs do backend
docker logs blog-backend-prod

# Verificar CORS
curl -H "Origin: http://seu-ec2-ip" -v http://localhost:3001/api/articles
```

### 3. PostgreSQL Não Conecta

```bash
# Verificar status do banco
docker exec blog-postgres-prod pg_isready -U user

# Ver logs
docker logs blog-postgres-prod

# Tentar conectar
docker exec -it blog-postgres-prod psql -U user -d blog -c "SELECT 1;"
```

### 4. DeepSeek/HF Não Gera Artigos

```bash
# Verificar token está carregado
docker exec blog-backend-prod env | grep HF_TOKEN

# Ver logs de erro
docker logs blog-backend-prod | grep -i deepseek

# Testar manualmente
curl -X POST http://localhost:3001/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"topic":"Test","style":"informative"}'
```

---

## Comandos Úteis

```bash
# Ver status dos containers
docker-compose -f docker-compose.prod.yml ps

# Ver logs em tempo real
docker-compose -f docker-compose.prod.yml logs -f

# Ver logs apenas do backend
docker-compose -f docker-compose.prod.yml logs -f backend

# Parar tudo
docker-compose -f docker-compose.prod.yml down

# Parar e remover volumes (CUIDADO!)
docker-compose -f docker-compose.prod.yml down -v

# Reiniciar um serviço
docker-compose -f docker-compose.prod.yml restart backend

# Executar comando no container
docker exec blog-backend-prod node -e "console.log(process.env.HF_TOKEN)"
```

---

## Monitoramento Contínuo

```bash
# Seguir logs em tempo real
docker-compose -f docker-compose.prod.yml logs -f

# Health check
watch -n 5 'curl -s http://localhost:3001/api/health | jq .'

# Disk space
df -h

# Container stats
docker stats
```

---

## Backup Database

```bash
# Fazer backup
docker exec blog-postgres-prod pg_dump -U user blog > backup-$(date +%Y%m%d-%H%M%S).sql

# Restaurar de backup
cat seu-backup.sql | docker exec -i blog-postgres-prod psql -U user -d blog
```

---

## Atualizar Aplicação

Se fizer mudanças no código:

```bash
# 1. Puxar mudanças
git pull

# 2. Rebuildar containers
docker-compose -f docker-compose.prod.yml up -d --build

# 3. Reiniciar (esperar 1-2 minutos para rebuild)
docker-compose -f docker-compose.prod.yml restart
```

---

## Problemas Comuns e Soluções

| Problema | Causa | Solução |
|----------|-------|---------|
| Porta 80 já em uso | Outro serviço usando | `sudo lsof -i :80` e kill |
| CORS error | `FRONTEND_URL` errada | Verificar variável em `.env.prod` |
| Artigos não carregam | DeepSeek offline | Verificar `HF_TOKEN` |
| Banco vazio | Migração não rodou | `docker logs blog-backend-prod` |
| Nginx timeout | Operação lenta | Aumentar timeout em `nginx.conf` |

---

## Resumo Rápido

```bash
# 1. SSH
ssh -i key.pem ec2-user@seu-ip

# 2. Clonar
git clone repo && cd assimetria

# 3. Configurar
cat > .env.prod << 'EOF'
HF_TOKEN=seu-token
VITE_API_URL=http://seu-ip:3001/api
FRONTEND_URL=http://seu-ip
DB_PASSWORD=senha-forte
EOF

# 4. Deploy
docker-compose -f docker-compose.prod.yml up -d --build

# 5. Verificar
docker-compose -f docker-compose.prod.yml ps
curl http://localhost/api/health

# 6. Acessar
# Browser: http://seu-ip
```

---

## ✅ Deploy Concluído!

Se chegou aqui, a aplicação está **rodando em produção** no AWS! 🎉

**Próximos passos (opcional):**
- Configurar DNS customizado
- Adicionar SSL/TLS (HTTPS)
- Configurar backup automático do banco
- Monitorar com CloudWatch
