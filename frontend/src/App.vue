<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import api from './api'

const tasks = ref([])
const categories = ref([])
const filters = ref({ category_id: '', status: '', priority: '' })

const statusLabels = { pending: 'Pendente', in_progress: 'Em andamento', done: 'Concluída' }
const priorityLabels = { low: 'Baixa', medium: 'Média', high: 'Alta' }
const formatDate = (date) => (date ? date.split('-').reverse().join('/') : '—')

function todayISO() {
  const d = new Date()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${d.getFullYear()}-${month}-${day}`
}

const isOverdue = (task) => Boolean(task.due_date) && task.status !== 'done' && task.due_date < todayISO()
const plural = (count, one, many) => `${count} ${count === 1 ? one : many}`

const emptyForm = () => ({
  id: null, title: '', description: '', status: 'pending',
  priority: 'low', due_date: '', category_id: '',
})
const form = ref(emptyForm())
const errors = ref({})

const loadError = ref('')
let lastTasksRequest = 0
const loading = ref(true)

const summary = computed(() => {
  const count = (status) => tasks.value.filter((task) => task.status === status).length
  return {
    total: tasks.value.length,
    pending: count('pending'),
    inProgress: count('in_progress'),
    done: count('done'),
    overdue: tasks.value.filter(isOverdue).length,
  }
})

async function loadTasks() {
  const requestId = ++lastTasksRequest
  try {
    const { data } = await api.get('/tasks', { params: filters.value })
    if (requestId !== lastTasksRequest) return
    tasks.value = data
    loadError.value = ''
  } catch {
    if (requestId !== lastTasksRequest) return
    loadError.value = 'Não foi possível carregar as tarefas. Verifique se a API está rodando.'
  } finally {
    if (requestId === lastTasksRequest) loading.value = false
  }
}

async function loadCategories() {
  try {
    const { data } = await api.get('/categories')
    categories.value = data
  } catch {
    loadError.value = 'Não foi possível carregar as categorias. Verifique se a API está rodando.'
  }
}

async function saveTask() {
  errors.value = {}
  const { id, ...payload } = form.value
  try {
    if (id) {
      await api.patch(`/tasks/${id}`, { task: payload })
    } else {
      await api.post('/tasks', { task: payload })
    }
    resetForm()
    loadTasks()
  } catch (error) {
    if (error.response?.status === 422) {
      errors.value = error.response.data
    } else {
      alert('Erro ao salvar a tarefa.')
    }
  }
}

function editTask(task) {
  errors.value = {}
  form.value = {
    id: task.id,
    title: task.title,
    description: task.description || '',
    status: task.status,
    priority: task.priority,
    due_date: task.due_date || '',
    category_id: task.category_id,
  }
}

function resetForm() {
  form.value = emptyForm()
  errors.value = {}
}

async function toggleDone(task) {
  const status = task.status === 'done' ? 'pending' : 'done'
  try {
    await api.patch(`/tasks/${task.id}`, { task: { status } })
    if (form.value.id === task.id) form.value.status = status
  } catch {
    alert('Erro ao atualizar a tarefa.')
  }
  loadTasks()
}

async function deleteTask(task) {
  if (!confirm(`Excluir a tarefa "${task.title}"?`)) return
  try {
    await api.delete(`/tasks/${task.id}`)
    if (form.value.id === task.id) resetForm()
  } catch {
    alert('Erro ao excluir a tarefa.')
  }
  loadTasks()
}

const newCategory = ref('')
const categoryErrors = ref([])

function showCategoryErrors(error) {
  if (error.response?.status === 422) {
    categoryErrors.value = Object.entries(error.response.data)
      .map(([field, messages]) => `${field}: ${messages.join(', ')}`)
  } else {
    alert('Erro na operação com a categoria.')
  }
}

async function createCategory() {
  categoryErrors.value = []
  try {
    await api.post('/categories', { category: { name: newCategory.value } })
    newCategory.value = ''
    loadCategories()
  } catch (error) {
    showCategoryErrors(error)
  }
}

async function renameCategory(category) {
  const name = prompt('Novo nome da categoria:', category.name)
  if (!name) return
  categoryErrors.value = []
  try {
    await api.patch(`/categories/${category.id}`, { category: { name } })
    loadCategories()
    loadTasks()
  } catch (error) {
    showCategoryErrors(error)
  }
}

async function deleteCategory(category) {
  if (!confirm(`Excluir a categoria "${category.name}"?`)) return
  categoryErrors.value = []
  try {
    await api.delete(`/categories/${category.id}`)
    if (filters.value.category_id === category.id) filters.value.category_id = ''
    loadCategories()
  } catch (error) {
    showCategoryErrors(error)
  }
}

watch(filters, loadTasks, { deep: true })

onMounted(() => {
  loadCategories()
  loadTasks()
})
</script>

<template>
  <div class="app">
    <header class="header">
      <h1>Minhas tarefas</h1>
      <p>Organize suas tarefas por categoria, status e prioridade.</p>
    </header>

    <section class="card">
      <h2>{{ form.id ? 'Editar tarefa' : 'Nova tarefa' }}</h2>
      <form class="task-form" @submit.prevent="saveTask">
        <label class="field full">
          <span>Título</span>
          <input v-model="form.title" placeholder="Ex.: Estudar Vue" />
        </label>

        <label class="field full">
          <span>Descrição</span>
          <textarea v-model="form.description" rows="2" placeholder="Opcional"></textarea>
        </label>

        <label class="field">
          <span>Categoria</span>
          <select v-model="form.category_id">
            <option value="" disabled>Selecione</option>
            <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
          </select>
        </label>

        <label class="field">
          <span>Status</span>
          <select v-model="form.status">
            <option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
          </select>
        </label>

        <label class="field">
          <span>Prioridade</span>
          <select v-model="form.priority">
            <option v-for="(label, key) in priorityLabels" :key="key" :value="key">{{ label }}</option>
          </select>
        </label>

        <label class="field">
          <span>Vencimento</span>
          <input type="date" v-model="form.due_date" />
        </label>

        <div class="form-actions">
          <button v-if="form.id" type="button" class="btn btn-ghost" @click="resetForm">Cancelar</button>
          <button type="submit" class="btn btn-primary">
            {{ form.id ? 'Salvar alterações' : 'Criar tarefa' }}
          </button>
        </div>
      </form>

      <ul v-if="Object.keys(errors).length" class="errors">
        <li v-for="(messages, field) in errors" :key="field">{{ field }}: {{ messages.join(', ') }}</li>
      </ul>
    </section>

    <section class="card">
      <div class="card-header">
        <div>
          <h2>Tarefas</h2>
          <p v-if="!loading && tasks.length" class="summary">
            {{ plural(summary.total, 'tarefa', 'tarefas') }} ·
            {{ plural(summary.pending, 'pendente', 'pendentes') }} ·
            {{ summary.inProgress }} em andamento ·
            {{ plural(summary.done, 'concluída', 'concluídas') }}
            <span v-if="summary.overdue" class="overdue">· {{ plural(summary.overdue, 'atrasada', 'atrasadas') }}</span>
          </p>
        </div>
        <div class="filters">
          <select v-model="filters.category_id">
            <option value="">Todas as categorias</option>
            <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
          </select>
          <select v-model="filters.status">
            <option value="">Todos os status</option>
            <option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
          </select>
          <select v-model="filters.priority">
            <option value="">Todas as prioridades</option>
            <option v-for="(label, key) in priorityLabels" :key="key" :value="key">{{ label }}</option>
          </select>
        </div>
      </div>

      <p v-if="loadError" class="load-error">{{ loadError }}</p>

      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Tarefa</th>
              <th>Categoria</th>
              <th>Status</th>
              <th>Prioridade</th>
              <th>Vencimento</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="task in tasks" :key="task.id" :class="{ 'is-done': task.status === 'done' }">
              <td class="title-cell">
                <label class="task-title">
                  <input
                    type="checkbox"
                    :checked="task.status === 'done'"
                    :aria-label="`Marcar ${task.title} como concluída`"
                    @change="toggleDone(task)"
                  />
                  <span>
                    <strong>{{ task.title }}</strong>
                    <small v-if="task.description">{{ task.description }}</small>
                  </span>
                </label>
              </td>
              <td>{{ task.category.name }}</td>
              <td><span class="badge" :class="`status-${task.status}`">{{ statusLabels[task.status] }}</span></td>
              <td><span class="badge" :class="`priority-${task.priority}`">{{ priorityLabels[task.priority] }}</span></td>
              <td class="due-cell" :class="{ overdue: isOverdue(task) }">
                {{ formatDate(task.due_date) }}
                <small v-if="isOverdue(task)">atrasada</small>
              </td>
              <td>
                <div class="actions">
                  <button class="btn btn-sm btn-ghost" @click="editTask(task)">Editar</button>
                  <button class="btn btn-sm btn-danger" @click="deleteTask(task)">Excluir</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-if="loading" class="empty">Carregando…</p>
      <p v-else-if="!loadError && tasks.length === 0" class="empty">Nenhuma tarefa encontrada.</p>
    </section>

    <section class="card">
      <h2>Categorias</h2>
      <form class="inline-form" @submit.prevent="createCategory">
        <input v-model="newCategory" placeholder="Nome da nova categoria" />
        <button type="submit" class="btn btn-primary">Adicionar</button>
      </form>

      <ul v-if="categoryErrors.length" class="errors">
        <li v-for="message in categoryErrors" :key="message">{{ message }}</li>
      </ul>

      <ul class="category-list">
        <li v-for="c in categories" :key="c.id">
          <span>{{ c.name }}</span>
          <div class="actions">
            <button class="btn btn-sm btn-ghost" @click="renameCategory(c)">Renomear</button>
            <button class="btn btn-sm btn-danger" @click="deleteCategory(c)">Excluir</button>
          </div>
        </li>
      </ul>
    </section>
  </div>
</template>

<style>
:root {
  --bg: #f4f5f7;
  --surface: #ffffff;
  --text: #1f2937;
  --muted: #6b7280;
  --border: #e5e7eb;
  --primary: #4f46e5;
  --primary-hover: #4338ca;
  --danger: #dc2626;
}

* { box-sizing: border-box; }

body {
  margin: 0;
  font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg);
  color: var(--text);
}

.app { max-width: 1000px; margin: 0 auto; padding: 40px 16px; }

.header { margin-bottom: 24px; }
.header h1 { margin: 0; font-size: 28px; }
.header p { margin: 4px 0 0; color: var(--muted); }

.card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}
.card h2 { margin: 0 0 16px; font-size: 18px; }

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}
.card-header h2 { margin: 0; }
.summary { margin: 4px 0 0; font-size: 13px; color: var(--muted); }

/* Formulário */
.task-form { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.field { display: flex; flex-direction: column; gap: 6px; font-size: 14px; }
.field span { font-weight: 500; color: var(--muted); }
.field.full { grid-column: 1 / -1; }
.form-actions { grid-column: 1 / -1; display: flex; justify-content: flex-end; gap: 8px; }

input, textarea, select {
  width: 100%;
  font: inherit;
  font-size: 14px;
  padding: 8px 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  background: var(--surface);
  color: var(--text);
}
textarea { resize: vertical; }
input:focus, textarea:focus, select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
}

/* Botões */
.btn {
  font: inherit;
  font-size: 14px;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid transparent;
  cursor: pointer;
  white-space: nowrap;
  transition: background 0.15s;
}
.btn-primary { background: var(--primary); color: #fff; }
.btn-primary:hover { background: var(--primary-hover); }
.btn-ghost { background: transparent; border-color: var(--border); color: var(--text); }
.btn-ghost:hover { background: var(--bg); }
.btn-danger { background: transparent; border-color: #fecaca; color: var(--danger); }
.btn-danger:hover { background: #fef2f2; }
.btn-sm { padding: 4px 10px; font-size: 13px; }

/* Filtros e tabela */
.filters { display: flex; flex-wrap: wrap; gap: 8px; }
.filters select { width: auto; }

.table-wrapper { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; font-size: 14px; }
th {
  text-align: left;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--muted);
  padding: 10px 12px;
  border-bottom: 1px solid var(--border);
}
td { padding: 12px; border-bottom: 1px solid var(--border); vertical-align: middle; }
tbody tr:last-child td { border-bottom: none; }
tbody tr:hover { background: #fafafa; }
.title-cell small { display: block; margin-top: 2px; color: var(--muted); }
.task-title { display: flex; align-items: flex-start; gap: 10px; cursor: pointer; }
.task-title input {
  width: 16px;
  height: 16px;
  margin: 2px 0 0;
  padding: 0;
  flex-shrink: 0;
  cursor: pointer;
  accent-color: var(--primary);
}
.is-done td { color: var(--muted); }
.is-done .task-title strong { font-weight: 500; text-decoration: line-through; }
.due-cell { white-space: nowrap; }
.due-cell small { display: block; font-size: 12px; }
.overdue { color: var(--danger); font-weight: 500; }
.actions { display: flex; justify-content: flex-end; gap: 6px; }

.badge {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
}
.status-pending { background: #fef3c7; color: #92400e; }
.status-in_progress { background: #dbeafe; color: #1e40af; }
.status-done { background: #dcfce7; color: #166534; }
.priority-low { background: #f3f4f6; color: #374151; }
.priority-medium { background: #ffedd5; color: #9a3412; }
.priority-high { background: #fee2e2; color: #991b1b; }

.empty { margin: 0; padding: 24px 0; text-align: center; color: var(--muted); }

/* Categorias */
.inline-form { display: flex; gap: 8px; margin-bottom: 16px; }
.category-list { list-style: none; margin: 0; padding: 0; }
.category-list li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--border);
}
.category-list li:last-child { border-bottom: none; }

.errors {
  margin: 16px 0 0;
  padding: 12px 16px 12px 32px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 8px;
  color: var(--danger);
  font-size: 14px;
}

.load-error {
  margin: 0 0 16px;
  padding: 12px 16px;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 8px;
  color: var(--danger);
  font-size: 14px;
}

@media (max-width: 640px) {
  .task-form { grid-template-columns: 1fr 1fr; }
  .card { padding: 16px; }
}
</style>