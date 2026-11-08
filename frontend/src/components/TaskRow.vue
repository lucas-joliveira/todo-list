<script setup>
import { computed } from 'vue'
import BaseButton from './BaseButton.vue'
import { statusLabels, priorityLabels } from '@/utils/labels'
import { formatDate, isOverdue } from '@/utils/format'

const props = defineProps({
  task: { type: Object, required: true },
})
const emit = defineEmits(['toggle', 'edit', 'delete'])

const done = computed(() => props.task.status === 'done')
const overdue = computed(() => isOverdue(props.task))
</script>

<template>
  <tr class="task-row" :class="{ 'is-done': done }">
    <td>
      <label class="task-title">
        <input
          type="checkbox"
          :checked="done"
          :aria-label="`Marcar ${task.title} como concluída`"
          @change="emit('toggle')"
        />
        <span>
          <strong>{{ task.title }}</strong>
          <small v-if="task.description">{{ task.description }}</small>
        </span>
      </label>
    </td>
    <td>{{ task.category.name }}</td>
    <td><span class="status" :class="`status-${task.status}`">{{ statusLabels[task.status] }}</span></td>
    <td>
      <span class="priority" :class="`priority-${task.priority}`">
        <span class="dot" aria-hidden="true"></span>{{ priorityLabels[task.priority] }}
      </span>
    </td>
    <td class="due-cell" :class="{ overdue }">
      {{ formatDate(task.due_date) }}
      <small v-if="overdue">atrasada</small>
    </td>
    <td>
      <div class="actions">
        <BaseButton variant="ghost" size="sm" @click="emit('edit')">Editar</BaseButton>
        <BaseButton variant="danger" size="sm" @click="emit('delete')">Excluir</BaseButton>
      </div>
    </td>
  </tr>
</template>

<style scoped>
td { padding: 12px; border-bottom: 1px solid var(--border); vertical-align: middle; }
.task-row:last-child td { border-bottom: none; }
.task-row:hover { background: var(--surface-hover); }

.task-title { display: flex; align-items: flex-start; gap: 10px; cursor: pointer; }
.task-title input {
  width: 16px;
  height: 16px;
  margin: 2px 0 0;
  padding: 0;
  flex-shrink: 0;
  cursor: pointer;
  accent-color: var(--accent);
}
.task-title small { display: block; margin-top: 2px; color: var(--muted); }
.is-done td { color: var(--muted); }
.is-done .task-title strong { font-weight: 500; text-decoration: line-through; }

.status, .priority { font-size: 13px; white-space: nowrap; }
.status-pending { color: var(--text); }
.status-in_progress { color: var(--accent-text); font-weight: 500; }
.status-done { color: var(--muted); }

.priority { display: inline-flex; align-items: center; gap: 6px; }
.dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.priority-low .dot { background: #a8a29e; }
.priority-medium .dot { background: #d97706; }
.priority-high .dot { background: #dc2626; }

.due-cell { white-space: nowrap; }
.due-cell small { display: block; font-size: 12px; }
</style>
