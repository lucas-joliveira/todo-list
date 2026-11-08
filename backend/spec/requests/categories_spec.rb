require "rails_helper"

RSpec.describe "Categories", type: :request do
  describe "GET /categories" do
    it "lista as categorias" do
      create(:category, name: "Trabalho")
      create(:category, name: "Pessoal")

      get "/categories"

      expect(response).to have_http_status(:ok)
      expect(json.pluck("name")).to contain_exactly("Trabalho", "Pessoal")
    end

    it "devolve as categorias em ordem alfabética" do
      create(:category, name: "Trabalho")
      create(:category, name: "Estudos")
      create(:category, name: "Pessoal")

      get "/categories"

      expect(json.pluck("name")).to eq(%w[Estudos Pessoal Trabalho])
    end
  end

  describe "GET /categories/:id" do
    it "mostra uma categoria" do
      category = create(:category, name: "Estudos")

      get "/categories/#{category.id}"

      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Estudos")
    end

    it "responde 404 quando a categoria não existe" do
      get "/categories/0"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /categories" do
    it "cria uma categoria e responde 201" do
      expect {
        post "/categories", params: { category: { name: "Casa" } }, as: :json
      }.to change(Category, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Casa")
    end

    it "responde 422 com a mensagem quando o nome está vazio" do
      post "/categories", params: { category: { name: "" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["name"]).to include("Nome não pode ficar em branco")
    end

    it "responde 422 quando o nome já existe, mesmo com outra caixa" do
      create(:category, name: "Casa")

      post "/categories", params: { category: { name: "CASA" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["name"]).to include("Nome já está em uso")
    end
  end

  describe "PATCH /categories/:id" do
    it "renomeia a categoria" do
      category = create(:category, name: "Antigo")

      patch "/categories/#{category.id}", params: { category: { name: "Novo" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(category.reload.name).to eq("Novo")
    end

    it "responde 422 quando o novo nome é inválido" do
      category = create(:category, name: "Antigo")

      patch "/categories/#{category.id}", params: { category: { name: "" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(category.reload.name).to eq("Antigo")
    end
  end

  describe "DELETE /categories/:id" do
    it "exclui uma categoria sem tarefas e responde 204" do
      category = create(:category)

      expect { delete "/categories/#{category.id}" }.to change(Category, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "não exclui uma categoria com tarefas e responde 422" do
      category = create(:category)
      create(:task, category: category)

      expect { delete "/categories/#{category.id}" }.not_to change(Category, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json["base"]).to include("Não é possível excluir: existem tarefas vinculadas")
    end
  end
end
