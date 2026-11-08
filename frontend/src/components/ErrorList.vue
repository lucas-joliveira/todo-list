<script setup>
defineProps({
  messages: { type: Array, default: () => [] },
})
</script>

<template>
  <ul v-if="messages.length" class="errors">
    <li v-for="message in messages" :key="message">{{ message }}</li>
  </ul>
</template>

<style scoped>
.errors {
  margin: 16px 0 0;
  padding: 12px 16px 12px 32px;
  background: var(--danger-bg);
  border: 1px solid var(--danger-border);
  border-radius: 8px;
  color: var(--danger);
  font-size: 14px;
}
</style>
