#!/bin/bash

# Blog Docker Helper Script

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   Blog com IA - Docker Helper${NC}"
echo -e "${BLUE}================================${NC}\n"

show_help() {
    echo "Uso: ./docker.sh [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start       - Inicia containers em modo desenvolvimento"
    echo "  stop        - Para todos os containers"
    echo "  restart     - Reinicia todos os containers"
    echo "  logs        - Mostra logs de todos os containers"
    echo "  logs-be     - Mostra logs apenas do backend"
    echo "  logs-fe     - Mostra logs apenas do frontend"
    echo "  build       - Rebuilda as imagens"
    echo "  clean       - Remove containers, volumes e imagens"
    echo "  prod        - Inicia em modo produção"
    echo "  status      - Mostra status dos containers"
    echo "  shell-be    - Abre shell no container do backend"
    echo "  shell-fe    - Abre shell no container do frontend"
    echo ""
}

case "$1" in
    start)
        echo -e "${GREEN}Iniciando containers em modo desenvolvimento...${NC}"
        docker-compose up -d
        echo -e "${GREEN}✓ Containers iniciados!${NC}"
        echo -e "Frontend: ${BLUE}http://localhost:5173${NC}"
        echo -e "Backend: ${BLUE}http://localhost:3001/api/articles${NC}"
        ;;
    
    stop)
        echo -e "${YELLOW}Parando containers...${NC}"
        docker-compose down
        echo -e "${GREEN}✓ Containers parados${NC}"
        ;;
    
    restart)
        echo -e "${YELLOW}Reiniciando containers...${NC}"
        docker-compose restart
        echo -e "${GREEN}✓ Containers reiniciados${NC}"
        ;;
    
    logs)
        docker-compose logs -f
        ;;
    
    logs-be)
        docker-compose logs -f backend
        ;;
    
    logs-fe)
        docker-compose logs -f frontend
        ;;
    
    build)
        echo -e "${GREEN}Rebuilding imagens...${NC}"
        docker-compose build --no-cache
        echo -e "${GREEN}✓ Build completo${NC}"
        ;;
    
    clean)
        echo -e "${YELLOW}Removendo containers, volumes e imagens...${NC}"
        docker-compose down -v --rmi all --remove-orphans
        echo -e "${GREEN}✓ Limpeza completa${NC}"
        ;;
    
    prod)
        echo -e "${GREEN}Iniciando em modo PRODUÇÃO...${NC}"
        docker-compose -f docker-compose.prod.yml up -d
        echo -e "${GREEN}✓ Produção iniciada!${NC}"
        echo -e "Frontend: ${BLUE}http://localhost${NC}"
        echo -e "Backend: ${BLUE}http://localhost:3001/api/articles${NC}"
        ;;
    
    status)
        docker-compose ps
        ;;
    
    shell-be)
        echo -e "${BLUE}Abrindo shell no backend...${NC}"
        docker exec -it blog-backend sh
        ;;
    
    shell-fe)
        echo -e "${BLUE}Abrindo shell no frontend...${NC}"
        docker exec -it blog-frontend sh
        ;;
    
    *)
        show_help
        ;;
esac
