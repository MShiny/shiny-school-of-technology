class Subject < ApplicationRecord
  has_many :degree_subjects, dependent: :destroy
  has_many :degrees, through: :degree_subjects
  has_many :courses, dependent: :destroy
  has_many :personal_project_subjects, dependent: :destroy
  has_many :personal_projects, through: :personal_project_subjects

  enum :status, {
    not_started: "not_started",
    learning: "learning",
    practicing: "practicing",
    completed: "completed",
    paused: "paused"
  }, default: "not_started", validate: true

  validates :name, presence: true

  scope :ordered, -> { order(:name) }
end
