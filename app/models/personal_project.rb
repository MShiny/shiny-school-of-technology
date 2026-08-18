class PersonalProject < ApplicationRecord
  has_many :personal_project_subjects, dependent: :destroy
  has_many :subjects, through: :personal_project_subjects

  enum :status, {
    idea: "idea",
    planned: "planned",
    in_progress: "in_progress",
    completed: "completed",
    paused: "paused"
  }, default: "idea", validate: true

  validates :name, presence: true

  scope :ordered, -> { order(:name) }
  scope :active_or_planned, -> { where(status: [ "in_progress", "planned" ]) }
end
