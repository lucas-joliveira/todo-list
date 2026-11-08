<script setup>
import { computed } from 'vue'
import { isOverdue, plural } from '@/utils/format'

const props = defineProps({
  tasks: { type: Array, required: true },
})

const summary = computed(() => {
  const count = (status) => props.tasks.filter((task) => task.status === status).length
  return {
    total: props.tasks.length,
    pending: count('pending'),
    inProgress: count('in_progress'),
    done: count('done'),
    overdue: props.tasks.filter(isOverdue).length,
  }
})
</script>

<template>
  <p v-if="summary.total" class="summary">
    {{ plural(summary.total, 'tarefa', 'tarefas') }} ·
    {{ plural(summary.pending, 'pendente', 'pendentes') }} ·
    {{ summary.inProgress }} em andamento ·
    {{ plural(summary.done, 'concluída', 'concluídas') }}
    <span v-if="summary.overdue" class="overdue">· {{ plural(summary.overdue, 'atrasada', 'atrasadas') }}</span>
  </p>
</template>

<style scoped>
.summary { margin: 4px 0 0; font-size: 13px; color: var(--muted); }
</style>
