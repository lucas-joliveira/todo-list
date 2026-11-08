<script setup>
import { ref, watch, onMounted } from 'vue'
import BaseButton from './BaseButton.vue'
import ErrorList from './ErrorList.vue'
import { statusLabels, priorityLabels } from '@/utils/labels'

const props = defineProps({
  task: { type: Object, default: null },
  categories: { type: Array, required: true },
  errors: { type: Array, default: () => [] },
})
const emit = defineEmits(['save', 'cancel'])

// Cópia local: editar o formulário não altera a tarefa da lista antes de salvar.
function toForm(task) {
  return {
    id: task?.id ?? null,
    title: task?.title ?? '',
    description: task?.description ?? '',
    status: task?.status ?? 'pending',
    priority: task?.priority ?? 'low',
    due_date: task?.due_date ?? '',
    category_id: task?.category_id ?? '',
  }
}

const form = ref(toForm(props.task))
const titleInput = ref(null)

// Se o status mudar pelo checkbox da lista enquanto a tarefa está aberta, o formulário acompanha.
watch(() => props.task?.status, (status) => {
  if (status) form.value.status = status
})

onMounted(() => titleInput.value?.focus())
</script>

<template>
  <section class="card">
    <h2>{{ form.id ? 'Editar tarefa' : 'Nova tarefa' }}</h2>
    <form class="task-form" @submit.prevent="emit('save', { ...form })">
      <label class="field full">
        <span>Título</span>
        <input ref="titleInput" v-model="form.title" placeholder="Ex.: Fazer compras" />
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
        <input v-model="form.due_date" type="date" />
      </label>

      <div class="form-actions">
        <BaseButton variant="ghost" @click="emit('cancel')">Cancelar</BaseButton>
        <BaseButton type="submit">{{ form.id ? 'Salvar alterações' : 'Criar tarefa' }}</BaseButton>
      </div>
    </form>

    <ErrorList :messages="errors" />
  </section>
</template>

<style scoped>
.task-form { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.field { display: flex; flex-direction: column; gap: 6px; font-size: 14px; }
.field span { font-weight: 500; color: var(--muted); }
.field.full { grid-column: 1 / -1; }
.form-actions { grid-column: 1 / -1; display: flex; justify-content: flex-end; gap: 8px; }

@media (max-width: 640px) {
  .task-form { grid-template-columns: 1fr 1fr; }
}
</style>
