#!/bin/bash
# init-ec2.sh
# Script de inicialização para AWS EC2
# Instala Docker, Docker Compose e prepara o ambiente

set -e  # Exit on error

echo "======================================"
echo "🚀 Inicializando EC2 para Blog com IA"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Update sistema
echo "📦 Atualizando sistema..."
sudo yum update -y > /dev/null 2>&1
echo -e "${GREEN}✓ Sistema atualizado${NC}"
echo ""

# Step 2: Instalar Docker
echo "🐳 Instalando Docker..."
sudo yum install -y docker > /dev/null 2>&1
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
echo -e "${GREEN}✓ Docker instalado${NC}"
echo ""

# Step 3: Instalar Docker Compose
echo "🐳 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose
echo -e "${GREEN}✓ Docker Compose instalado${NC}"
echo ""

# Step 4: Instalar Git
echo "📥 Instalando Git..."
sudo yum install -y git > /dev/null 2>&1
echo -e "${GREEN}✓ Git instalado${NC}"
echo ""

# Step 5: Verificar instalações
echo "🧪 Verificando instalações..."
echo ""
echo "Docker:"
docker --version
echo ""
echo "Docker Compose:"
docker-compose --version
echo ""
echo "Git:"
git --version
echo ""

# Step 6: Clone do repositório (OPCIONAL - pode fazer manualmente)
echo "📚 Pronto para clonar repositório"
echo ""
echo "Para clonar o projeto:"
echo "  git clone seu-repo-url"
echo "  cd assimetria"
echo ""
echo "Depois execute:"
echo "  bash infra/scripts/deploy.sh"
echo ""

echo -e "${GREEN}✅ EC2 inicializada com sucesso!${NC}"
