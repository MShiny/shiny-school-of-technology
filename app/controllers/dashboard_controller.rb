class DashboardController < ApplicationController
  def index
    @todays_goal = DailyGoal.find_or_create_today!
    @active_degrees = Degree.active.ordered
    @current_courses = Course.in_progress.includes(:subject).ordered
    @recent_goals = DailyGoal.recent.limit(7)
    @monthly_stats = DailyGoal.monthly_stats
    @current_streak = DailyGoal.current_streak
  end
end
