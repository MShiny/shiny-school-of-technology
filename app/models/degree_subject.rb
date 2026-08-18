class DegreeSubject < ApplicationRecord
  belongs_to :degree
  belongs_to :subject

  validates :subject_id, uniqueness: { scope: :degree_id, message: "is already linked to this degree" }
end
