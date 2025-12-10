# 🤖 Guia de Configuração Hugging Face

## 1️⃣ Criar Conta no Hugging Face

1. Ir para https://huggingface.co
2. Clicar em **"Sign Up"**
3. Preencher:
   - Email
   - Username
   - Password
   - Aceitar termos
4. Confirmar email
5. Pronto! Conta criada ✅

## 2️⃣ Gerar Token de API

1. Ir para https://huggingface.co/settings/tokens
2. Clicar em **"New token"**
3. Preencher:
   - **Name**: `blog-ai` (ou qualquer nome)
   - **Type**: `read` (é suficiente para gerar artigos)
   - **Role**: `User`
4. Clicar **"Generate token"**
5. **Copiar o token** (começa com `hf_`)

⚠️ **Guarde bem!** O token só aparece uma vez. Se perder, gere um novo.

## 3️⃣ Adicionar Token ao Projeto

### Opção A: Arquivo `.env` (Desenvolvimento Local)

1. Abrir `backend/.env`:

```env
PORT=3001
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=blog
DB_USER=user
DB_PASSWORD=password

# Cole o token aqui ⬇️
HUGGINGFACE_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

2. Salvar e reiniciar o backend

### Opção B: Docker Compose (Com Docker)

1. Abrir `.env` na raiz do projeto:

```env
DB_HOST=postgres
DB_PORT=5432
DB_NAME=blog
DB_USER=user
DB_PASSWORD=password

# Cole o token aqui ⬇️
HUGGINGFACE_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

2. Reiniciar containers:

```bash
docker-compose down
docker-compose up --build
```

## 4️⃣ Verificar se Funcionou

### Via API HTTP

```bash
curl -X POST http://localhost:3001/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"topic": "Docker", "style": "informative"}'
```

### Esperado: Resposta JSON com artigo gerado ✅

```json
{
  "id": "1",
  "title": "Docker: Guia Completo",
  "description": "Docker é uma plataforma...",
  "content": "Conteúdo completo do artigo...",
  "tags": ["docker", "educação", "tutorial"],
  "status": "published",
  "views": 0,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### Se receber erro:

```json
{
  "error": "HUGGINGFACE_API_KEY not configured"
}
```

👉 Verifique se o token foi adicionado corretamente ao `.env`

## 5️⃣ Modelos Disponíveis

O backend usa **Mistral-7B-Instruct-v0.2** por padrão (mais recente e confiável).

| Modelo | Velocidade | Qualidade | Status |
|--------|-----------|-----------|--------|
| **Mistral-7B-Instruct-v0.2** | Rápido ⚡ | Excelente ⭐⭐⭐⭐ | ✅ Recomendado |
| HuggingFaceH4/zephyr-7b-beta | Rápido ⚡ | Excelente ⭐⭐⭐⭐ | ✅ Funciona |
| meta-llama/Llama-2-7B-chat | Médio ⚙️ | Boa ⭐⭐⭐ | ✅ Funciona |
| google/flan-t5-large | Rápido ⚡ | Média ⭐⭐ | ✅ Alternativa |
| mistralai/Mistral-7B-Instruct-v0.1 | ❌ | ❌ | ❌ Descontinuado (erro 410) |

### Se receber erro 410 (Model not found):

O modelo foi removido da Hugging Face. Tente um dos modelos acima.

**Para trocar modelo:**

1. Editar `backend/src/services/aiClient.js`:

```javascript
// Linha ~27, mudar:
const modelUrl = 'https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta';
```

2. Reiniciar backend:
```bash
docker-compose restart backend
```

### Verificar Modelos Disponíveis:

Ir para: https://huggingface.co/models?pipeline_tag=text-generation&sort=trending

E procurar por modelos com badge "Inference API" 🟢

## 6️⃣ Limites e Quotas

### Free Tier (Gratuito)
- ✅ Sem limite de requisições
- ✅ Sem cartão de crédito
- ⚠️ Modelos podem estar lentos durante picos
- ⚠️ Prioridade baixa na fila

### Taxa de Requisições
- ~30 requisições por minuto
- Se exceder, aguarde 1 minuto e tente novamente

### Como Aumentar Limite?
1. Ir para https://huggingface.co/settings/billing/overview
2. Selecionar plano pago (opcional)
3. Usar créditos para acesso prioritário

## 7️⃣ Troubleshooting

### ❌ Erro: "AI generation failed, using fallback: Hugging Face API error: Request failed with status code 410"

**Causa:** Modelo foi removido ou descontinuado da Hugging Face

**Solução:**

1. Usar modelo mais recente (v0.2):
```bash
# Editar backend/src/services/aiClient.js linha ~27
const modelUrl = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2';
```

2. Ou usar modelo alternativo:
```javascript
const modelUrl = 'https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta';
```

3. Reiniciar:
```bash
docker-compose restart backend
```

4. Testar:
```bash
curl -X POST http://localhost:3001/api/articles/generate \
  -H "Content-Type: application/json" \
  -d '{"topic": "Python"}'
```

**Fallback:** Se falhar mesmo assim, o sistema usa gerador local automaticamente ✅

### ❌ Erro: "HUGGINGFACE_API_KEY not configured"

**Solução:**
```bash
# 1. Verificar se .env existe
cat backend/.env

# 2. Se não existe, criar:
echo "HUGGINGFACE_API_KEY=hf_seu_token" >> backend/.env

# 3. Reiniciar backend
docker-compose restart backend
```

### ❌ Erro: "Invalid API token - please check your HUGGINGFACE_API_KEY"

**Causa:** Token inválido ou expirado

**Solução:**
1. Regenerar token em https://huggingface.co/settings/tokens
2. Atualizar `.env`
3. Reiniciar backend

### ❌ Erro: "Rate limit exceeded"

**Causa:** Muitas requisições em pouco tempo

**Solução:**
- Aguarde 1-2 minutos
- Tente novamente
- Fallback local é usado automaticamente

### ❌ Erro: "Model no longer available"

**Causa:** Modelo descontinuado

**Solução:**
- Ver seção "Modelos Disponíveis"
- Trocar para modelo ativo (v0.2)

### ✅ Teste Rápido de Conectividade

```bash
# Verificar se token é válido
curl -H "Authorization: Bearer $HUGGINGFACE_API_KEY" \
  https://huggingface.co/api/whoami

# Esperado: informações do seu perfil
```

## 8️⃣ Verificar Quotas

1. Ir para https://huggingface.co/settings/billing/overview
2. Ver uso do mês
3. Ver limite restante

## 9️⃣ Usar com Docker em Produção

### `.env.production`

```env
DB_HOST=postgres
DB_PORT=5432
DB_NAME=blog
DB_USER=prod_user
DB_PASSWORD=super_secret_password

HUGGINGFACE_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NODE_ENV=production
```

### Deploy:

```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 🔟 Alternativas se Hugging Face Falhar

Se o token não funcionar ou atingir limite:

1. **Fallback Local** (automático)
   - Gera artigos com templates
   - Sempre funciona
   - Sem qualidade de IA, mas suficiente

2. **JSONPlaceholder** (para testes)
   - Editar `aiClient.js` para usar essa função
   - Mock data realista

3. **Outras APIs de IA:**
   - OpenAI (pago)
   - Anthropic Claude (pago)
   - Local LLM (Ollama, etc.)

## 🎯 Resumo Rápido

```bash
# 1. Copiar token de https://huggingface.co/settings/tokens
HUGGINGFACE_API_KEY=hf_...

# 2. Adicionar ao backend/.env
echo "HUGGINGFACE_API_KEY=hf_..." >> backend/.env

# 3. Reiniciar
docker-compose restart backend

# 4. Testar
curl http://localhost:3001/api/articles/generate

# ✅ Pronto!
```

## 💡 Dicas

- ✅ Guarde o token em lugar seguro
- ✅ Nunca commitar `.env` no Git (usar `.env.example`)
- ✅ Regenere token se publicar código acidentalmente
- ✅ Monitore uso em https://huggingface.co/settings/billing/overview
- ✅ Use fallback como backup
- ✅ Teste com tópicos diferentes para validar qualidade

## 📞 Suporte

Se tiver problemas:
1. Ver logs: `docker-compose logs backend`
2. Verificar token em https://huggingface.co/settings/tokens
3. Tentar regenerar token
4. Consultar https://huggingface.co/docs/api-inference

---

**Pronto para gerar artigos com IA!** 🚀
