class Task < ApplicationRecord
  belongs_to :category

  enum :status, { pending: 0, in_progress: 1, done: 2 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: true

  validates :title, presence: true
end
