import { ref } from 'vue'
import api from '@/api'
import { errorMessages } from '@/utils/format'

// Estado e chamadas à API das categorias.
export function useCategories() {
  const categories = ref([])
  const newName = ref('')
  const errors = ref([])
  const loadError = ref('')

  function handleError(error) {
    if (error.response?.status === 422) {
      errors.value = errorMessages(error.response.data)
    } else {
      alert('Erro na operação com a categoria.')
    }
  }

  async function load() {
    try {
      const { data } = await api.get('/categories')
      categories.value = data
      loadError.value = ''
    } catch {
      loadError.value = 'Não foi possível carregar as categorias. Verifique se a API está rodando.'
    }
  }

  async function create() {
    errors.value = []
    try {
      await api.post('/categories', { category: { name: newName.value } })
      newName.value = ''
      load()
    } catch (error) {
      handleError(error)
    }
  }

  // Retorna true se a categoria foi renomeada.
  async function rename(category) {
    const name = prompt('Novo nome da categoria:', category.name)
    if (!name) return false
    errors.value = []
    try {
      await api.patch(`/categories/${category.id}`, { category: { name } })
      load()
      return true
    } catch (error) {
      handleError(error)
      return false
    }
  }

  // Retorna true se a categoria foi excluída.
  async function remove(category) {
    if (!confirm(`Excluir a categoria "${category.name}"?`)) return false
    errors.value = []
    try {
      await api.delete(`/categories/${category.id}`)
      load()
      return true
    } catch (error) {
      handleError(error)
      return false
    }
  }

  return { categories, newName, errors, loadError, load, create, rename, remove }
}
