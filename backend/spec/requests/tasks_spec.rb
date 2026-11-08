require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:category) { create(:category, name: "Trabalho") }

  describe "GET /tasks" do
    it "lista as tarefas com a categoria dentro do JSON" do
      create(:task, title: "Responder e-mails", category: category)

      get "/tasks"

      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(1)
      expect(json.first["title"]).to eq("Responder e-mails")
      expect(json.first["category"]["name"]).to eq("Trabalho")
    end

    it "ordena pela data de vencimento" do
      create(:task, title: "Depois", due_date: Date.current + 10)
      create(:task, title: "Antes", due_date: Date.current + 1)

      get "/tasks"

      expect(json.pluck("title")).to eq(%w[Antes Depois])
    end

    describe "filtros" do
      let(:other_category) { create(:category, name: "Pessoal") }

      before do
        create(:task, title: "A", category: category, status: :pending, priority: :high)
        create(:task, title: "B", category: category, status: :done, priority: :low)
        create(:task, title: "C", category: other_category, status: :pending, priority: :low)
      end

      it "filtra por categoria" do
        get "/tasks", params: { category_id: other_category.id }

        expect(json.pluck("title")).to contain_exactly("C")
      end

      it "filtra por status" do
        get "/tasks", params: { status: "pending" }

        expect(json.pluck("title")).to contain_exactly("A", "C")
      end

      it "filtra por prioridade" do
        get "/tasks", params: { priority: "low" }

        expect(json.pluck("title")).to contain_exactly("B", "C")
      end

      it "combina os filtros" do
        get "/tasks", params: { category_id: category.id, status: "pending", priority: "high" }

        expect(json.pluck("title")).to contain_exactly("A")
      end

      it "ignora filtros vazios" do
        get "/tasks", params: { category_id: "", status: "", priority: "" }

        expect(json.size).to eq(3)
      end
    end
  end

  describe "GET /tasks/:id" do
    it "mostra uma tarefa" do
      task = create(:task, title: "Estudar Rails", category: category)

      get "/tasks/#{task.id}"

      expect(response).to have_http_status(:ok)
      expect(json["title"]).to eq("Estudar Rails")
      expect(json["category"]["name"]).to eq("Trabalho")
    end

    it "responde 404 quando a tarefa não existe" do
      get "/tasks/0"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /tasks" do
    let(:valid_params) do
      { task: { title: "Nova tarefa", priority: "high", due_date: "2026-12-01", category_id: category.id } }
    end

    it "cria a tarefa, responde 201 e aplica o status padrão" do
      expect { post "/tasks", params: valid_params, as: :json }.to change(Task, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["status"]).to eq("pending")
      expect(json["priority"]).to eq("high")
      expect(json["category"]["name"]).to eq("Trabalho")
    end

    it "responde 422 com as mensagens em português quando faltam dados" do
      post "/tasks", params: { task: { title: "" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["title"]).to include("Título não pode ficar em branco")
      expect(json["category"]).to include("Categoria é obrigatória")
    end

    it "responde 422 quando a data de vencimento é inválida" do
      post "/tasks", params: { task: valid_params[:task].merge(due_date: "not-a-date") }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["due_date"]).to include("Vencimento não é uma data válida")
    end

    it "responde 422 dizendo que a categoria não existe quando o id é desconhecido" do
      post "/tasks", params: { task: valid_params[:task].merge(category_id: 0) }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["category"]).to eq([ "Categoria não existe" ])
    end

    it "responde 422 quando o status é inválido" do
      post "/tasks", params: { task: valid_params[:task].merge(status: "xyz") }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["status"]).to include("Status não é um valor válido")
    end

    it "responde 400 quando a chave task não é um objeto" do
      post "/tasks", params: { task: "texto solto" }, as: :json

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /tasks/:id" do
    it "atualiza a tarefa" do
      task = create(:task, status: :pending, category: category)

      patch "/tasks/#{task.id}", params: { task: { status: "done" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(task.reload).to be_done
    end

    it "responde 422 quando os dados são inválidos" do
      task = create(:task, title: "Original", category: category)

      patch "/tasks/#{task.id}", params: { task: { title: "" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(task.reload.title).to eq("Original")
    end
  end

  describe "DELETE /tasks/:id" do
    it "exclui a tarefa e responde 204" do
      task = create(:task, category: category)

      expect { delete "/tasks/#{task.id}" }.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
