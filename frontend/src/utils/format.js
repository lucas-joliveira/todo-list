// "2026-11-10" -> "10/11/2026"
export const formatDate = (date) => (date ? date.split('-').reverse().join('/') : '—')

// Data de hoje no fuso local, no formato da API (toISOString usaria UTC).
export function todayISO() {
  const d = new Date()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${d.getFullYear()}-${month}-${day}`
}

export const isOverdue = (task) =>
  Boolean(task.due_date) && task.status !== 'done' && task.due_date < todayISO()

export const plural = (count, one, many) => `${count} ${count === 1 ? one : many}`

// Resposta 422 da API ({ campo: [mensagens] }) -> lista simples de mensagens.
export const errorMessages = (data) => Object.values(data ?? {}).flat()
