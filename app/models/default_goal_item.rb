class DefaultGoalItem < ApplicationRecord
  validates :text, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  before_validation :assign_next_position, on: :create

  private

  # Simple integer positions (no drag-and-drop): new items are appended
  # after the current highest position by default, and can be reordered
  # later by editing the number directly.
  def assign_next_position
    return if position.present?

    self.position = (DefaultGoalItem.maximum(:position) || 0) + 1
  end
end
