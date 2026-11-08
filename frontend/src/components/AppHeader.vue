<script setup>
import BaseButton from './BaseButton.vue'

defineProps({
  showNewButton: { type: Boolean, default: true },
})
const emit = defineEmits(['new-task'])
</script>

<template>
  <header class="header">
    <div>
      <h1>Minhas tarefas</h1>
      <p>Organize suas tarefas por categoria, status e prioridade.</p>
    </div>
    <BaseButton v-if="showNewButton" @click="emit('new-task')">+ Nova tarefa</BaseButton>
  </header>
</template>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 24px;
}
h1 { margin: 0; font-size: 26px; font-weight: 650; letter-spacing: -0.01em; }
h1::after {
  content: '';
  display: block;
  width: 40px;
  height: 4px;
  margin-top: 6px;
  border-radius: 2px;
  background: var(--accent);
}
p { margin: 4px 0 0; color: var(--muted); }
</style>
