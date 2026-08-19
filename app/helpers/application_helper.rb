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

  STATUS_DOT_CLASSES = {
    "completed" => "status-success",
    "met" => "status-success",
    "active" => "status-accent",
    "in_progress" => "status-accent",
    "learning" => "status-warning",
    "practicing" => "status-warning",
    "partial" => "status-warning",
    "pending" => "status-neutral",
    "planned" => "status-neutral",
    "not_started" => "status-neutral",
    "idea" => "status-neutral",
    "paused" => "status-neutral",
    "dropped" => "status-danger",
    "not_met" => "status-danger"
  }.freeze

  def status_dot(status)
    content_tag(:span, "", class: "status-dot #{STATUS_DOT_CLASSES.fetch(status.to_s, 'status-neutral')}")
  end

  # A simple, timeless-when-in-doubt greeting for the dashboard header.
  def time_based_greeting
    hour = Time.current.hour
    if hour < 12
      "Good morning"
    elsif hour < 18
      "Good afternoon"
    else
      "Good evening"
    end
  end
end
