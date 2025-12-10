#!/bin/bash
# deploy-aws.sh
# Script para fazer deploy automático no AWS EC2

set -e  # Exit on error

echo "======================================"
echo "🚀 Deploy Blog com IA para AWS"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Verificar se está num diretório correto
if [ ! -f "docker-compose.prod.yml" ]; then
    echo -e "${RED}✗ Erro: docker-compose.prod.yml não encontrado${NC}"
    echo "Execute este script na raiz do projeto"
    exit 1
fi

echo -e "${GREEN}✓ Arquivo docker-compose.prod.yml encontrado${NC}"
echo ""

# Step 2: Verificar se .env.prod existe
if [ ! -f ".env.prod" ]; then
    echo -e "${YELLOW}⚠ Arquivo .env.prod não encontrado${NC}"
    echo ""
    echo "Criando .env.prod com valores padrão..."
    echo ""
    
    read -p "🔑 HF_TOKEN (Hugging Face): " HF_TOKEN
    read -p "🌐 Backend IP/DNS (ex: seu-ec2-ip.compute.amazonaws.com): " BACKEND_URL
    read -p "🎨 Frontend URL (ex: seu-ec2-ip): " FRONTEND_URL
    read -p "🔐 PostgreSQL Password: " DB_PASSWORD
    
    cat > .env.prod << EOF
# AWS Deployment Configuration
NODE_ENV=production
PORT=3001

# Hugging Face / DeepSeek AI
HF_TOKEN=$HF_TOKEN

# API URLs
VITE_API_URL=http://$BACKEND_URL:3001/api
FRONTEND_URL=http://$FRONTEND_URL

# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=blog
DB_USER=user
DB_PASSWORD=$DB_PASSWORD
EOF

    echo -e "${GREEN}✓ Arquivo .env.prod criado${NC}"
    echo ""
else
    echo -e "${GREEN}✓ Arquivo .env.prod encontrado${NC}"
    echo ""
    echo "Conteúdo de .env.prod:"
    echo "========================"
    cat .env.prod | grep -v "PASSWORD" | head -10
    echo "========================"
    echo ""
fi

# Step 3: Load environment variables
echo "📦 Carregando variáveis de ambiente..."
set -a
source .env.prod
set +a
echo -e "${GREEN}✓ Variáveis carregadas${NC}"
echo ""

# Step 4: Verificar Docker
echo "🐳 Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker não está instalado${NC}"
    echo "Instale Docker: https://docs.docker.com/install/"
    exit 1
fi
echo -e "${GREEN}✓ Docker instalado${NC}"

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose não está instalado${NC}"
    echo "Instale Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose instalado${NC}"
echo ""

# Step 5: Build e Deploy
echo "🔨 Building e iniciando containers..."
echo ""

docker-compose -f docker-compose.prod.yml up -d --build

echo ""
echo -e "${GREEN}✓ Containers iniciados${NC}"
echo ""

# Step 6: Wait for services
echo "⏳ Aguardando serviços ficarem prontos..."
echo ""

for i in {1..30}; do
    if curl -s http://localhost:3001/api/health | grep -q "ok"; then
        echo -e "${GREEN}✓ Backend está pronto${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

echo ""
echo ""

# Step 7: Final checks
echo "🧪 Testando comunicação..."
echo ""

if curl -s http://localhost/api/health | grep -q "ok"; then
    echo -e "${GREEN}✓ Frontend → Backend comunicação OK${NC}"
else
    echo -e "${RED}✗ Frontend → Backend FALHOU${NC}"
fi

echo ""

# Step 8: Display URLs
echo "======================================"
echo -e "${GREEN}✅ DEPLOY COMPLETO!${NC}"
echo "======================================"
echo ""
echo "📍 URLs:"
echo "   Frontend:     http://$FRONTEND_URL"
echo "   Backend API:  http://$BACKEND_URL:3001/api"
echo "   Health Check: http://$BACKEND_URL:3001/api/health"
echo ""
echo "📊 Verificar status:"
echo "   docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "📝 Ver logs:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🛑 Parar deploy:"
echo "   docker-compose -f docker-compose.prod.yml down"
echo ""
