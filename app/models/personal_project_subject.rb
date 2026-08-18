class PersonalProjectSubject < ApplicationRecord
  belongs_to :personal_project
  belongs_to :subject

  validates :subject_id, uniqueness: { scope: :personal_project_id, message: "is already linked to this project" }
end
