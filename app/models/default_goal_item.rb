class DefaultGoalItem < ApplicationRecord
  # Ruby's Date#wday numbering (0 = Sunday .. 6 = Saturday), so matching a
  # date against stored weekdays is a plain array lookup -- no day-name
  # parsing required anywhere else in the app.
  WEEKDAY_NAMES = {
    0 => "Sunday",
    1 => "Monday",
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday"
  }.freeze

  # Monday-first, matching the calendar's week start, for both the settings
  # form's weekday order and the human-readable recurrence label.
  ORDERED_WEEKDAYS = [ 1, 2, 3, 4, 5, 6, 0 ].freeze

  WEEKDAY_OPTIONS = ORDERED_WEEKDAYS.map { |wday| [ wday, WEEKDAY_NAMES.fetch(wday)[0, 3] ] }.freeze

  validates :text, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :weekdays_contain_only_valid_values
  validate :recurrence_present_when_active

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  # Checkbox groups submit an empty string alongside real values (via the
  # hidden-field fallback that guarantees the param key is present even when
  # every box is unchecked), so strip blanks before they ever reach the
  # array column.
  def weekdays=(value)
    super(Array(value).reject(&:blank?).map(&:to_i))
  end

  before_validation :assign_next_position, on: :create
  before_validation :clear_weekdays_when_daily

  # Daily items apply every day; otherwise, applies only on the date's
  # matching weekday. Inactive items never apply.
  def applies_on?(date)
    return false unless active?

    daily? || weekdays.include?(date.wday)
  end

  # A short, scannable description of when this item repeats, e.g.
  # "Every day", "Every Monday", "Saturday & Sunday", "Mon, Wed, Fri".
  def recurrence_label
    return "Every day" if daily?
    return "No schedule set" if weekdays.blank?

    names = ordered_weekday_names
    case names.size
    when 1 then "Every #{names.first}"
    when 2 then names.join(" & ")
    else names.map { |name| name[0, 3] }.join(", ")
    end
  end

  private

  def ordered_weekday_names
    weekdays.sort_by { |wday| ORDERED_WEEKDAYS.index(wday) }.map { |wday| WEEKDAY_NAMES.fetch(wday) }
  end

  # Simple integer positions (no drag-and-drop): new items are appended
  # after the current highest position by default, and can be reordered
  # later by editing the number directly.
  def assign_next_position
    return if position.present?

    self.position = (DefaultGoalItem.maximum(:position) || 0) + 1
  end

  # Weekday selections are meaningless (and would be confusing to display)
  # once an item is marked Daily, so keep the stored data clean.
  def clear_weekdays_when_daily
    self.weekdays = [] if daily?
  end

  def weekdays_contain_only_valid_values
    return if weekdays.blank?

    errors.add(:weekdays, "must only contain valid weekdays") if (weekdays - WEEKDAY_NAMES.keys).any?
  end

  # An active item needs a real schedule -- either daily, or at least one
  # weekday -- so it's clear when it will actually be copied into a
  # checklist. Inactive items are exempt, so legacy/retired items don't need
  # to be revisited just to keep them valid.
  def recurrence_present_when_active
    return unless active?
    return if daily?

    errors.add(:base, "must repeat daily or on at least one weekday") if weekdays.blank?
  end
end
