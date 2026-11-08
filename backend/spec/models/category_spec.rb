require "rails_helper"

RSpec.describe Category, type: :model do
  describe "validações" do
    it "é válida com um nome" do
      expect(build(:category, name: "Trabalho")).to be_valid
    end

    it "exige o nome" do
      category = build(:category, name: "")

      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("não pode ficar em branco")
    end

    it "não permite nomes repetidos" do
      create(:category, name: "Trabalho")
      category = build(:category, name: "Trabalho")

      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("já está em uso")
    end

    it "não diferencia maiúsculas de minúsculas na unicidade" do
      create(:category, name: "Trabalho")

      expect(build(:category, name: "TRABALHO")).not_to be_valid
    end

    it "remove espaços nas pontas do nome antes de salvar" do
      category = create(:category, name: "  Estudos  ")

      expect(category.name).to eq("Estudos")
    end
  end

  describe "índice único no banco" do
    it "impede duplicatas mesmo sem passar pelas validações" do
      create(:category, name: "Pessoal")
      duplicate = build(:category, name: "pessoal")

      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "exclusão" do
    it "pode ser excluída quando não tem tarefas" do
      category = create(:category)

      expect(category.destroy).to be_truthy
      expect(Category.exists?(category.id)).to be(false)
    end

    it "não pode ser excluída quando tem tarefas" do
      category = create(:category)
      create(:task, category: category)

      expect(category.destroy).to be(false)
      expect(category.errors[:base]).to include("Não é possível excluir: existem tarefas vinculadas")
      expect(Category.exists?(category.id)).to be(true)
    end
  end
end
