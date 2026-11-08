<script setup>
defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'ghost', 'danger'].includes(value),
  },
  size: { type: String, default: 'md', validator: (value) => ['md', 'sm'].includes(value) },
  type: { type: String, default: 'button' },
})
</script>

<template>
  <button :type="type" class="btn" :class="[`btn-${variant}`, { 'btn-sm': size === 'sm' }]">
    <slot />
  </button>
</template>

<style scoped>
.btn {
  font: inherit;
  font-size: 14px;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid transparent;
  cursor: pointer;
  white-space: nowrap;
  transition: background 0.15s;
}
.btn-primary { background: var(--primary); color: #fff; }
.btn-primary:hover { background: var(--primary-hover); }
.btn-ghost { background: transparent; border-color: var(--border); color: var(--text); }
.btn-ghost:hover { background: var(--bg); }
.btn-danger { background: transparent; border-color: var(--danger-border); color: var(--danger); }
.btn-danger:hover { background: var(--danger-bg); }
.btn-sm { padding: 4px 10px; font-size: 13px; }
</style>
