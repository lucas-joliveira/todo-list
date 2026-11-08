<script setup>
import BaseButton from './BaseButton.vue'
import ErrorList from './ErrorList.vue'

defineProps({
  categories: { type: Array, required: true },
  errors: { type: Array, default: () => [] },
})
const emit = defineEmits(['create', 'rename', 'delete'])

// O nome digitado fica no pai, que limpa o campo quando a criação dá certo.
const newName = defineModel('newName', { default: '' })
</script>

<template>
  <section class="card">
    <h2>Categorias</h2>
    <form class="inline-form" @submit.prevent="emit('create')">
      <input v-model="newName" placeholder="Nome da nova categoria" aria-label="Nome da nova categoria" />
      <BaseButton type="submit">Adicionar</BaseButton>
    </form>

    <ErrorList :messages="errors" />

    <ul class="category-list">
      <li v-for="category in categories" :key="category.id">
        <span>{{ category.name }}</span>
        <div class="actions">
          <BaseButton variant="ghost" size="sm" @click="emit('rename', category)">Renomear</BaseButton>
          <BaseButton variant="danger" size="sm" @click="emit('delete', category)">Excluir</BaseButton>
        </div>
      </li>
    </ul>
  </section>
</template>

<style scoped>
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
</style>
