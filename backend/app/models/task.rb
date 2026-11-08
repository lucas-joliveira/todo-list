class Task < ApplicationRecord
  # A presença da categoria é validada abaixo, para diferenciar "não informada" de "não existe".
  belongs_to :category, optional: true

  enum :status, { pending: 0, in_progress: 1, done: 2 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: true

  validates :title, presence: true
  validate :category_must_exist
  validate :due_date_must_be_valid

  private

  def category_must_exist
    return if category.present?

    errors.add(:category, category_id.blank? ? :required : :not_found)
  end

  # O Rails converte uma data inválida em nil sem avisar; aqui isso vira erro de validação.
  def due_date_must_be_valid
    return if due_date_before_type_cast.blank? || due_date.present?

    errors.add(:due_date, :invalid_date)
  end
end
