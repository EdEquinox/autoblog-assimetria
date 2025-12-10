#!/bin/bash
# deploy.sh
# Script de deploy para a aplicação
# Cria .env.prod, faz pull do git e inicia containers

set -e  # Exit on error

echo "======================================"
echo "🚀 Deploy - Blog com IA"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Verificar se está no diretório correto
if [ ! -f "docker-compose.prod.yml" ]; then
    echo -e "${RED}✗ Erro: docker-compose.prod.yml não encontrado${NC}"
    echo "Execute este script a partir da raiz do projeto (assimetria/)"
    exit 1
fi
echo -e "${GREEN}✓ Arquivo docker-compose.prod.yml encontrado${NC}"
echo ""

# Step 2: Git pull (atualizar código)
echo "📥 Atualizando código..."
git pull origin main 2>/dev/null || echo -e "${YELLOW}⚠ Não foi possível fazer git pull${NC}"
echo ""

# Step 3: Criar .env.prod se não existir
if [ ! -f ".env.prod" ]; then
    echo -e "${YELLOW}⚠ Arquivo .env.prod não encontrado${NC}"
    echo ""
    echo "Criando .env.prod com valores padrão..."
    echo "⚠️  IMPORTANTE: Atualize os valores antes de fazer deploy!"
    echo ""
    
    cat > .env.prod << 'EOF'
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=blog
DB_USER=user
DB_PASSWORD=sua-senha-forte-aqui

# Hugging Face / DeepSeek
HF_TOKEN=seu-hf-token-aqui

# URLs (ATUALIZE COM SEU IP!)
VITE_API_URL=http://seu-ec2-ip:3001/api
FRONTEND_URL=http://seu-ec2-ip
EOF

    echo -e "${YELLOW}⚠️  Edite .env.prod e atualize os valores:${NC}"
    echo ""
    echo "  nano .env.prod"
    echo ""
    echo "Depois execute novamente:"
    echo "  bash infra/scripts/deploy.sh"
    echo ""
    exit 0
fi

echo -e "${GREEN}✓ Arquivo .env.prod encontrado${NC}"
echo ""

# Step 4: Verificar variáveis críticas
echo "🔍 Verificando variáveis de ambiente..."
if grep -q "seu-ec2-ip" .env.prod; then
    echo -e "${RED}✗ Erro: Atualize 'seu-ec2-ip' em .env.prod${NC}"
    echo ""
    echo "Edite .env.prod e substitua 'seu-ec2-ip' pelo IP público da instância"
    exit 1
fi
if grep -q "seu-hf-token" .env.prod; then
    echo -e "${RED}✗ Erro: Atualize 'seu-hf-token' em .env.prod${NC}"
    exit 1
fi
if grep -q "sua-senha-forte" .env.prod; then
    echo -e "${RED}✗ Erro: Atualize 'sua-senha-forte-aqui' em .env.prod${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Variáveis verificadas${NC}"
echo ""

# Step 5: Carregar variáveis de ambiente
echo "📦 Carregando variáveis..."
set -a
source .env.prod
set +a
echo -e "${GREEN}✓ Variáveis carregadas${NC}"
echo ""

# Step 6: Fazer build e deploy
echo "🏗️  Building e iniciando containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker-compose -f docker-compose.prod.yml up -d --build
echo ""

# Step 7: Aguardar serviços
echo "⏳ Aguardando serviços ficarem saudáveis..."
sleep 5
for i in {1..30}; do
    if curl -s http://localhost:3001/api/health | grep -q "ok"; then
        echo -e "${GREEN}✓ Backend está saudável${NC}"
        break
    fi
    echo -n "."
    sleep 1
done
echo ""
echo ""

# Step 8: Status final
echo "======================================"
echo -e "${GREEN}✅ DEPLOY COMPLETO!${NC}"
echo "======================================"
echo ""
echo "Status dos containers:"
docker-compose -f docker-compose.prod.yml ps
echo ""
echo "URLs:"
echo "   Frontend:     http://$FRONTEND_URL"
echo "   Backend API:  http://$FRONTEND_URL:3001/api"
echo "   Health Check: http://$FRONTEND_URL:3001/api/health"
echo ""
echo "Comandos úteis:"
echo "   Ver logs:      docker-compose -f docker-compose.prod.yml logs -f"
echo "   Parar:         docker-compose -f docker-compose.prod.yml down"
echo "   Reiniciar:     docker-compose -f docker-compose.prod.yml restart"
echo ""
