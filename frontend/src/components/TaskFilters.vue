<script setup>
import { statusLabels, priorityLabels } from '@/utils/labels'

defineProps({
  categories: { type: Array, required: true },
})

// Cada filtro é um v-model próprio: o pai decide onde guardar o valor.
const categoryId = defineModel('categoryId', { default: '' })
const status = defineModel('status', { default: '' })
const priority = defineModel('priority', { default: '' })
</script>

<template>
  <div class="filters">
    <select v-model="categoryId" aria-label="Filtrar por categoria">
      <option value="">Todas as categorias</option>
      <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
    </select>
    <select v-model="status" aria-label="Filtrar por status">
      <option value="">Todos os status</option>
      <option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
    </select>
    <select v-model="priority" aria-label="Filtrar por prioridade">
      <option value="">Todas as prioridades</option>
      <option v-for="(label, key) in priorityLabels" :key="key" :value="key">{{ label }}</option>
    </select>
  </div>
</template>

<style scoped>
.filters { display: flex; flex-wrap: wrap; gap: 8px; }
select { width: auto; }
</style>
