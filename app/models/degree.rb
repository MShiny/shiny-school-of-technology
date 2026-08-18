class Degree < ApplicationRecord
  has_many :degree_subjects, dependent: :destroy
  has_many :subjects, through: :degree_subjects

  enum :status, {
    planned: "planned",
    active: "active",
    completed: "completed",
    paused: "paused"
  }, default: "planned", validate: true

  validates :name, presence: true

  scope :ordered, -> { order(:name) }
end
