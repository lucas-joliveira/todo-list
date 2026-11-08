import { ref, watch } from 'vue'
import api from '@/api'
import { errorMessages } from '@/utils/format'

// Estado e chamadas à API das tarefas.
export function useTasks() {
  const tasks = ref([])
  const filters = ref({ category_id: '', status: '', priority: '' })
  const loading = ref(true)
  const loadError = ref('')
  let lastRequest = 0

  async function load() {
    // Só a resposta da requisição mais recente é aplicada (evita condição de corrida nos filtros).
    const requestId = ++lastRequest
    try {
      const { data } = await api.get('/tasks', { params: filters.value })
      if (requestId !== lastRequest) return
      tasks.value = data
      loadError.value = ''
    } catch {
      if (requestId !== lastRequest) return
      loadError.value = 'Não foi possível carregar as tarefas. Verifique se a API está rodando.'
    } finally {
      if (requestId === lastRequest) loading.value = false
    }
  }

  // Cria ou atualiza. Retorna { ok, errors } para o formulário decidir se fecha.
  async function save({ id, ...payload }) {
    try {
      if (id) {
        await api.patch(`/tasks/${id}`, { task: payload })
      } else {
        await api.post('/tasks', { task: payload })
      }
      load()
      return { ok: true, errors: [] }
    } catch (error) {
      if (error.response?.status === 422) {
        return { ok: false, errors: errorMessages(error.response.data) }
      }
      alert('Erro ao salvar a tarefa.')
      return { ok: false, errors: [] }
    }
  }

  // Alterna entre concluída e pendente. Retorna o novo status, ou null se falhar.
  async function toggleDone(task) {
    const status = task.status === 'done' ? 'pending' : 'done'
    let result = status
    try {
      await api.patch(`/tasks/${task.id}`, { task: { status } })
    } catch {
      alert('Erro ao atualizar a tarefa.')
      result = null
    }
    load()
    return result
  }

  // Retorna true se a tarefa foi excluída.
  async function remove(task) {
    if (!confirm(`Excluir a tarefa "${task.title}"?`)) return false
    let removed = true
    try {
      await api.delete(`/tasks/${task.id}`)
    } catch {
      alert('Erro ao excluir a tarefa.')
      removed = false
    }
    load()
    return removed
  }

  watch(filters, load, { deep: true })

  return { tasks, filters, loading, loadError, load, save, toggleDone, remove }
}
