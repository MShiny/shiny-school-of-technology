class Course < ApplicationRecord
  belongs_to :subject

  enum :status, {
    planned: "planned",
    in_progress: "in_progress",
    completed: "completed",
    paused: "paused",
    dropped: "dropped"
  }, default: "planned", validate: true

  validates :title, presence: true
  validates :progress_percentage,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true
  validates :roadmap_position,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true

  scope :ordered, -> { order(:title) }
  # Manual roadmap order within a subject: positioned courses first (ascending),
  # unpositioned courses last, then alphabetically as a tiebreaker.
  scope :roadmap_ordered, -> { order(Arel.sql("roadmap_position ASC NULLS LAST"), :title) }
end
