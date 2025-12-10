#!/bin/bash
# test-api-communication.sh
# Script para testar comunicação frontend-backend

echo "======================================"
echo "🧪 Teste de Comunicação Frontend-Backend"
echo "======================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verificar Backend
echo "1️⃣  Testando Backend..."
if curl -s http://localhost:3001/api/health | grep -q "ok"; then
    echo -e "${GREEN}✓ Backend está rodando${NC}"
else
    echo -e "${RED}✗ Backend NÃO está respondendo${NC}"
fi
echo ""

# 2. Verificar Frontend
echo "2️⃣  Testando Frontend..."
if curl -s http://localhost/api/health | grep -q "ok"; then
    echo -e "${GREEN}✓ Frontend (Nginx) está fazendo proxy corretamente${NC}"
else
    echo -e "${RED}✗ Frontend NÃO está fazendo proxy${NC}"
fi
echo ""

# 3. Verificar Database
echo "3️⃣  Testando Database..."
if docker exec blog-postgres pg_isready -U user 2>/dev/null | grep -q "accepting"; then
    echo -e "${GREEN}✓ PostgreSQL está conectado${NC}"
else
    echo -e "${RED}✗ PostgreSQL NÃO está respondendo${NC}"
fi
echo ""

# 4. Verificar CORS
echo "4️⃣  Verificando configuração CORS..."
BACKEND_LOGS=$(docker-compose logs backend 2>/dev/null | grep "CORS configured")
if [ ! -z "$BACKEND_LOGS" ]; then
    echo -e "${GREEN}✓ CORS configurado${NC}"
    echo "  $BACKEND_LOGS"
else
    echo -e "${YELLOW}⚠ CORS pode não estar configurado corretamente${NC}"
fi
echo ""

# 5. Verificar variáveis de ambiente
echo "5️⃣  Variáveis de Ambiente..."
echo ""
echo "Backend:"
docker exec blog-backend env 2>/dev/null | grep -E "FRONTEND_URL|NODE_ENV|HF_TOKEN" | head -5
echo ""
echo "Frontend:"
docker exec blog-frontend-prod env 2>/dev/null | grep -E "VITE_API_URL" | head -5
echo ""

# 6. Testar artigos
echo "6️⃣  Testando Geração de Artigos..."
RESPONSE=$(curl -s -X POST http://localhost:3001/api/articles/generate \
    -H "Content-Type: application/json" \
    -d '{"topic":"Test","style":"informative"}')

if echo $RESPONSE | grep -q "title"; then
    echo -e "${GREEN}✓ Geração de artigos funcionando${NC}"
    echo "  Resposta: $(echo $RESPONSE | jq -r '.title' 2>/dev/null || echo 'OK')"
else
    echo -e "${RED}✗ Erro na geração de artigos${NC}"
    echo "  Resposta: $RESPONSE"
fi
echo ""

echo "======================================"
echo "🎯 Resumo"
echo "======================================"
echo ""
echo "Frontend: http://localhost"
echo "Backend:  http://localhost:3001/api"
echo "Health:   http://localhost:3001/api/health"
echo ""
echo "Para debugging mais detalhado:"
echo "  docker-compose logs -f backend"
echo "  docker-compose logs -f frontend"
echo ""
