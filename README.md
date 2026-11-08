# To-Do List — Rails + Vue

Aplicação de lista de tarefas com **API REST em Ruby on Rails** e **frontend em Vue.js**, rodando inteira em containers Docker.

Cada tarefa pertence a uma categoria e tem título, descrição, status, prioridade e data de vencimento. A tela lista as tarefas com filtros por categoria, status e prioridade, e permite criar, editar e excluir tarefas e categorias.

## Stack

| Camada | Tecnologia |
|---|---|
| Backend | Ruby 3.3.3, Rails 8.1 (modo API), ActiveRecord |
| Banco de dados | PostgreSQL 16 |
| Frontend | Vue 3 (Composition API), Vite, Axios |
| Infraestrutura | Docker e Docker Compose |

## Arquitetura

```
todo-list/
├── backend/             # API Rails (MVC: models, controllers e JSON como view)
├── frontend/            # SPA em Vue
└── docker-compose.yml   # serviços db, backend e frontend
```

| Serviço | Porta no host | Descrição |
|---|---|---|
| `frontend` | 5173 | Servidor de desenvolvimento do Vite |
| `backend` | 3000 | API Rails |
| `db` | 5433 | PostgreSQL (porta interna 5432) |

Dentro da rede do Docker Compose, o backend acessa o banco pelo nome do serviço (`db:5432`). O navegador acessa a API por `localhost:3000`.

## Como rodar

Pré-requisitos: **Docker** e **Docker Compose**. Não é preciso instalar Ruby, Node nem PostgreSQL na máquina.

```bash
git clone https://github.com/lucas-joliveira/todo-list.git
cd todo-list
docker compose up --build
```

Na primeira execução, o backend cria o banco e roda as migrations automaticamente (`db:prepare`).

Para popular o banco com dados de exemplo, em outro terminal:

```bash
docker compose exec backend bin/rails db:seed
```

Acesse:

- Aplicação: http://localhost:5173
- API: http://localhost:3000/tasks

Para parar: `docker compose down`. Para apagar também os dados do banco: `docker compose down -v`.

## API

### Categorias

| Método | Rota | Ação |
|---|---|---|
| GET | `/categories` | Lista as categorias |
| GET | `/categories/:id` | Mostra uma categoria |
| POST | `/categories` | Cria uma categoria |
| PATCH/PUT | `/categories/:id` | Atualiza uma categoria |
| DELETE | `/categories/:id` | Exclui uma categoria (retorna 422 se ela tiver tarefas) |

### Tarefas

| Método | Rota | Ação |
|---|---|---|
| GET | `/tasks` | Lista as tarefas (aceita filtros) |
| GET | `/tasks/:id` | Mostra uma tarefa |
| POST | `/tasks` | Cria uma tarefa |
| PATCH/PUT | `/tasks/:id` | Atualiza uma tarefa |
| DELETE | `/tasks/:id` | Exclui uma tarefa |

Filtros por query string, combináveis entre si:

```
GET /tasks?category_id=1&status=pending&priority=high
```

- `status`: `pending`, `in_progress`, `done`
- `priority`: `low`, `medium`, `high`

Exemplo de criação:

```bash
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"task":{"title":"Estudar Rails","priority":"high","due_date":"2026-12-01","category_id":1}}'
```

Erros de validação retornam **422** com as mensagens por campo:

```json
{ "title": ["can't be blank"], "category": ["must exist"] }
```

## Decisões técnicas

- **Status e prioridade como `enum` de inteiros**: o banco guarda números e a API expõe nomes legíveis. Com `validate: true`, um valor inválido gera erro 422 em vez de exceção.
- **Integridade em duas camadas**: as validações ficam no model (`presence`, `uniqueness`, `belongs_to`) e as restrições no banco (`null: false`, chave estrangeira).
- **Exclusão de categoria com tarefas é bloqueada** (`dependent: :restrict_with_error`) para não apagar tarefas sem querer.
- **Categoria incluída no JSON da tarefa**, com `includes(:category)` para evitar o problema de N+1 queries.
- **Configuração por variáveis de ambiente**: `DB_HOST`, `DB_PORT` e `VITE_API_URL` permitem rodar o mesmo código dentro e fora do Docker.
- **CORS** liberado apenas para as origens do frontend, configuráveis pela variável `CORS_ORIGINS` (padrão: `localhost:5173` e `127.0.0.1:5173`).

## Fluxo de desenvolvimento (GitFlow)

- `main`: versões entregues, marcadas com tags (`v1.0.0`).
- `develop`: integração das funcionalidades.
- `feature/*`: uma branch por funcionalidade, integrada à `develop` via pull request.
- `release/*`: preparação da entrega, integrada à `main` e à `develop`.

Commits seguem o padrão [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `chore:`, `docs:`).