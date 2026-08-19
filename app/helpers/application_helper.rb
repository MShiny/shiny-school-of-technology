module ApplicationHelper
  STATUS_BADGE_COLORS = {
    "completed" => "success",
    "met" => "success",
    "active" => "primary",
    "in_progress" => "info",
    "learning" => "warning",
    "practicing" => "warning",
    "partial" => "warning",
    "pending" => "secondary",
    "planned" => "secondary",
    "not_started" => "secondary",
    "idea" => "secondary",
    "paused" => "secondary",
    "dropped" => "danger",
    "not_met" => "danger"
  }.freeze

  def status_badge(status)
    color = STATUS_BADGE_COLORS.fetch(status.to_s, "secondary")
    content_tag(:span, status.to_s.humanize, class: "badge rounded-pill text-bg-#{color}")
  end
end
