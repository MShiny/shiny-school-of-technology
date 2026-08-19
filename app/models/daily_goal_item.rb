class DailyGoalItem < ApplicationRecord
  belongs_to :daily_goal

  validates :text, presence: true

  scope :ordered, -> { order(:position, :id) }
end
