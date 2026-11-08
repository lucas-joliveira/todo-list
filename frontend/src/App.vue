<script setup>
import { ref, onMounted } from 'vue'
import AppHeader from '@/components/AppHeader.vue'
import TaskForm from '@/components/TaskForm.vue'
import TaskSummary from '@/components/TaskSummary.vue'
import TaskFilters from '@/components/TaskFilters.vue'
import TaskTable from '@/components/TaskTable.vue'
import CategoryManager from '@/components/CategoryManager.vue'
import { useTasks } from '@/composables/useTasks'
import { useCategories } from '@/composables/useCategories'

const {
  tasks, filters, loading, loadError: tasksError,
  load: loadTasks, save: saveTask, toggleDone, remove: removeTask,
} = useTasks()

const {
  categories, newName, errors: categoryErrors, loadError: categoriesError,
  load: loadCategories, create: createCategory, rename: renameCategory, remove: removeCategory,
} = useCategories()

// Formulário de tarefa: aberto para criar (task = null) ou editar uma tarefa.
const formOpen = ref(false)
const editingTask = ref(null)
const formErrors = ref([])

function openForm(task = null) {
  editingTask.value = task
  formErrors.value = []
  formOpen.value = true
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function closeForm() {
  formOpen.value = false
  editingTask.value = null
  formErrors.value = []
}

async function handleSave(form) {
  const result = await saveTask(form)
  if (result.ok) closeForm()
  else formErrors.value = result.errors
}

async function handleToggle(task) {
  const status = await toggleDone(task)
  if (status && editingTask.value?.id === task.id) {
    editingTask.value = { ...editingTask.value, status }
  }
}

async function handleDeleteTask(task) {
  const removed = await removeTask(task)
  if (removed && editingTask.value?.id === task.id) closeForm()
}

async function handleRenameCategory(category) {
  // A tabela mostra o nome da categoria, então as tarefas também são recarregadas.
  if (await renameCategory(category)) loadTasks()
}

async function handleDeleteCategory(category) {
  const removed = await removeCategory(category)
  if (removed && filters.value.category_id === category.id) filters.value.category_id = ''
}

onMounted(() => {
  loadCategories()
  loadTasks()
})
</script>

<template>
  <div class="app">
    <AppHeader :show-new-button="!formOpen" @new-task="openForm()" />

    <TaskForm
      v-if="formOpen"
      :key="editingTask?.id ?? 'new'"
      :task="editingTask"
      :categories="categories"
      :errors="formErrors"
      @save="handleSave"
      @cancel="closeForm"
    />

    <section class="card">
      <div class="card-header">
        <div>
          <h2>Tarefas</h2>
          <TaskSummary v-if="!loading" :tasks="tasks" />
        </div>
        <TaskFilters
          v-model:categoryId="filters.category_id"
          v-model:status="filters.status"
          v-model:priority="filters.priority"
          :categories="categories"
        />
      </div>

      <TaskTable
        :tasks="tasks"
        :loading="loading"
        :error="tasksError || categoriesError"
        @toggle="handleToggle"
        @edit="openForm"
        @delete="handleDeleteTask"
      />
    </section>

    <CategoryManager
      v-model:newName="newName"
      :categories="categories"
      :errors="categoryErrors"
      @create="createCategory"
      @rename="handleRenameCategory"
      @delete="handleDeleteCategory"
    />
  </div>
</template>

<style scoped>
.app { max-width: 1000px; margin: 0 auto; padding: 40px 16px; }

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}
.card-header h2 { margin: 0; }
</style>
