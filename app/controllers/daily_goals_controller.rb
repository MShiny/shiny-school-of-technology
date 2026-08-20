class DailyGoalsController < ApplicationController
  before_action :set_daily_goal, only: %i[ show edit update ]

  # Monthly calendar: the primary Daily Goals view. Every date in the grid is
  # clickable (past, today, or future) and takes you to that date's page,
  # where it's created on demand if it doesn't exist yet.
  def index
    @month = parse_month(params[:month])
    @previous_month = @month.prev_month
    @next_month = @month.next_month

    goals_by_date = DailyGoal.includes(:daily_goal_items)
                              .where(date: @month.all_month)
                              .index_by(&:date)

    @calendar_weeks = build_calendar_weeks(@month, goals_by_date)
  end

  # Secondary journal/list view of past + today's goals.
  def history
    @daily_goals = DailyGoal.includes(:daily_goal_items).recent
  end

  def show
  end

  def edit
  end

  def update
    if @daily_goal.update(daily_goal_params)
      redirect_to @daily_goal, notice: "Daily goal updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_daily_goal
    date = parse_date(params[:id])
    @daily_goal = DailyGoal.find_or_create_for_date!(date)
  end

  def parse_date(value)
    Date.iso8601(value.to_s)
  rescue ArgumentError, TypeError
    raise ActionController::RoutingError, "Invalid date: #{value}"
  end

  def parse_month(value)
    Date.strptime(value.to_s, "%Y-%m").beginning_of_month
  rescue ArgumentError, TypeError
    Date.current.beginning_of_month
  end

  # Builds a Monday-start grid of weeks covering the given month, padded
  # with the leading/trailing days needed to fill complete weeks. Days
  # outside the target month are still real, clickable dates (from the
  # adjacent month) -- just visually de-emphasized in the view.
  def build_calendar_weeks(month, goals_by_date)
    grid_start = month.beginning_of_month.beginning_of_week(:monday)
    grid_end = month.end_of_month.end_of_week(:monday)

    (grid_start..grid_end)
      .map { |date| { date: date, in_month: date.month == month.month, goal: goals_by_date[date] } }
      .each_slice(7)
      .to_a
  end

  def daily_goal_params
    params.require(:daily_goal).permit(:notes)
  end
end
