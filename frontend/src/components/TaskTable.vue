<script setup>
import TaskRow from './TaskRow.vue'

defineProps({
  tasks: { type: Array, required: true },
  loading: { type: Boolean, default: false },
  error: { type: String, default: '' },
})
const emit = defineEmits(['toggle', 'edit', 'delete'])
</script>

<template>
  <p v-if="error" class="load-error">{{ error }}</p>

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
        <TaskRow
          v-for="task in tasks"
          :key="task.id"
          :task="task"
          @toggle="emit('toggle', task)"
          @edit="emit('edit', task)"
          @delete="emit('delete', task)"
        />
      </tbody>
    </table>
  </div>

  <p v-if="loading" class="empty">Carregando…</p>
  <p v-else-if="!error && tasks.length === 0" class="empty">Nenhuma tarefa encontrada.</p>
</template>

<style scoped>
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

.empty { margin: 0; padding: 24px 0; text-align: center; color: var(--muted); }
.load-error {
  margin: 0 0 16px;
  padding: 12px 16px;
  background: var(--danger-bg);
  border: 1px solid var(--danger-border);
  border-radius: 8px;
  color: var(--danger);
  font-size: 14px;
}
</style>
