require "rails_helper"

RSpec.describe Task, type: :model do
  it "é válida com os dados da fábrica" do
    expect(build(:task)).to be_valid
  end

  describe "validações" do
    it "exige o título" do
      task = build(:task, title: "")

      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("não pode ficar em branco")
    end

    it "exige uma categoria" do
      task = build(:task, category: nil)

      expect(task).not_to be_valid
      expect(task.errors[:category]).to include("é obrigatória")
    end

    it "aceita tarefa sem descrição e sem vencimento" do
      expect(build(:task, description: nil, due_date: nil)).to be_valid
    end

    it "recusa uma data de vencimento inválida" do
      task = build(:task, due_date: "not-a-date")

      expect(task).not_to be_valid
      expect(task.errors[:due_date]).to include("não é uma data válida")
    end

    it "recusa uma data que não existe no calendário" do
      task = build(:task, due_date: "2026-02-30")

      expect(task).not_to be_valid
      expect(task.errors[:due_date]).to include("não é uma data válida")
    end

    it "avisa que a categoria não existe quando o id não corresponde a nenhuma" do
      task = build(:task, category: nil, category_id: 0)

      expect(task).not_to be_valid
      expect(task.errors[:category]).to eq([ "não existe" ])
    end
  end

  describe "valores padrão" do
    it "nasce pendente e com prioridade baixa" do
      task = Task.new

      expect(task.status).to eq("pending")
      expect(task.priority).to eq("low")
    end
  end

  describe "enum de status" do
    it "aceita os valores pending, in_progress e done" do
      expect(Task.statuses.keys).to eq(%w[pending in_progress done])
    end

    it "guarda o status como inteiro no banco" do
      task = create(:task, status: :done)

      expect(task.status_before_type_cast).to eq(2)
      expect(task).to be_done
    end

    it "transforma um status inválido em erro de validação, e não em exceção" do
      task = build(:task, status: "xyz")

      expect(task).not_to be_valid
      expect(task.errors[:status]).to include("não é um valor válido")
    end
  end

  describe "enum de prioridade" do
    it "aceita os valores low, medium e high" do
      expect(Task.priorities.keys).to eq(%w[low medium high])
    end

    it "transforma uma prioridade inválida em erro de validação" do
      task = build(:task, priority: "urgente")

      expect(task).not_to be_valid
      expect(task.errors[:priority]).to include("não é um valor válido")
    end
  end

  describe "associação com categoria" do
    it "pertence a uma categoria" do
      category = create(:category, name: "Estudos")
      task = create(:task, category: category)

      expect(task.category).to eq(category)
      expect(category.tasks).to contain_exactly(task)
    end
  end
end
