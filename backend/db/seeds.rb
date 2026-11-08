puts "Criando categorias..."
trabalho = Category.find_or_create_by!(name: "Trabalho")
pessoal  = Category.find_or_create_by!(name: "Pessoal")
estudos  = Category.find_or_create_by!(name: "Estudos")

puts "Criando tarefas..."
[
  { title: "Preparar apresentação", description: "Slides da reunião de sexta", status: :in_progress, priority: :high,   due_date: Date.today + 2,  category: trabalho },
  { title: "Responder e-mails",     description: nil,                          status: :pending,     priority: :medium, due_date: Date.today,      category: trabalho },
  { title: "Fazer compras",         description: "Arroz, feijão e café",       status: :pending,     priority: :low,    due_date: Date.today + 1,  category: pessoal },
  { title: "Pagar conta de luz",    description: nil,                          status: :done,        priority: :high,   due_date: Date.today - 3,  category: pessoal },
  { title: "Estudar Vue.js",        description: "Composition API e Axios",    status: :in_progress, priority: :medium, due_date: Date.today + 5,  category: estudos },
  { title: "Revisar para a prova",  description: nil,                          status: :pending,     priority: :high,   due_date: Date.today + 7,  category: estudos }
].each do |attrs|
  Task.find_or_create_by!(title: attrs[:title]) do |task|
    task.assign_attributes(attrs)
  end
end

puts "Pronto: #{Category.count} categorias e #{Task.count} tarefas."