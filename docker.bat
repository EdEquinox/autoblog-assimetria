@echo off
REM Blog Docker Helper Script para Windows

echo ================================
echo    Blog com IA - Docker Helper
echo ================================
echo.

if "%1"=="" goto :help
if "%1"=="start" goto :start
if "%1"=="stop" goto :stop
if "%1"=="restart" goto :restart
if "%1"=="logs" goto :logs
if "%1"=="logs-be" goto :logs_be
if "%1"=="logs-fe" goto :logs_fe
if "%1"=="build" goto :build
if "%1"=="clean" goto :clean
if "%1"=="prod" goto :prod
if "%1"=="status" goto :status
if "%1"=="shell-be" goto :shell_be
if "%1"=="shell-fe" goto :shell_fe
goto :help

:start
echo Iniciando containers em modo desenvolvimento...
docker-compose up -d
echo.
echo Containers iniciados!
echo Frontend: http://localhost:5173
echo Backend: http://localhost:3001/api/articles
goto :end

:stop
echo Parando containers...
docker-compose down
echo Containers parados
goto :end

:restart
echo Reiniciando containers...
docker-compose restart
echo Containers reiniciados
goto :end

:logs
docker-compose logs -f
goto :end

:logs_be
docker-compose logs -f backend
goto :end

:logs_fe
docker-compose logs -f frontend
goto :end

:build
echo Rebuilding imagens...
docker-compose build --no-cache
echo Build completo
goto :end

:clean
echo Removendo containers, volumes e imagens...
docker-compose down -v --rmi all --remove-orphans
echo Limpeza completa
goto :end

:prod
echo Iniciando em modo PRODUCAO...
docker-compose -f docker-compose.prod.yml up -d
echo.
echo Producao iniciada!
echo Frontend: http://localhost
echo Backend: http://localhost:3001/api/articles
goto :end

:status
docker-compose ps
goto :end

:shell_be
echo Abrindo shell no backend...
docker exec -it blog-backend sh
goto :end

:shell_fe
echo Abrindo shell no frontend...
docker exec -it blog-frontend sh
goto :end

:help
echo Uso: docker.bat [comando]
echo.
echo Comandos disponiveis:
echo   start       - Inicia containers em modo desenvolvimento
echo   stop        - Para todos os containers
echo   restart     - Reinicia todos os containers
echo   logs        - Mostra logs de todos os containers
echo   logs-be     - Mostra logs apenas do backend
echo   logs-fe     - Mostra logs apenas do frontend
echo   build       - Rebuilda as imagens
echo   clean       - Remove containers, volumes e imagens
echo   prod        - Inicia em modo producao
echo   status      - Mostra status dos containers
echo   shell-be    - Abre shell no container do backend
echo   shell-fe    - Abre shell no container do frontend
echo.
goto :end

:end
