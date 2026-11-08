FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Tarefa #{n}" }
    description { "Descrição de exemplo" }
    status { :pending }
    priority { :low }
    due_date { Date.current + 7 }
    category
  end
end
