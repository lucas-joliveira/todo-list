class TasksController < ApplicationController
  before_action :set_task, only: %i[ show update destroy ]

  # GET /tasks
  def index
    @tasks = Task.includes(:category).order(:due_date)
    @tasks = @tasks.where(category_id: params[:category_id]) if params[:category_id].present?
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(priority: params[:priority]) if params[:priority].present?

    render json: @tasks, include: :category
  end

  # GET /tasks/1
  def show
    render json: @task, include: :category
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)

    if @task.save
      render json: @task, include: :category, status: :created, location: @task
    else
      render json: @task.errors.to_hash(true), status: :unprocessable_content
    end
  end

    # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      render json: @task, include: :category
    else
      render json: @task.errors.to_hash(true), status: :unprocessable_content
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :title, :description, :status, :priority, :due_date, :category_id ])
    end
end
