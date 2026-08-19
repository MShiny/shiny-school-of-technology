class DashboardController < ApplicationController
  def index
    @todays_goal = DailyGoal.find_or_create_today!
    @todays_goal.daily_goal_items.load
    @active_degrees = Degree.active.ordered
    @current_courses = Course.in_progress.includes(:subject).ordered
    @recent_goals = DailyGoal.includes(:daily_goal_items).recent.limit(7)
    @monthly_stats = DailyGoal.monthly_stats
    @current_streak = DailyGoal.current_streak

    # in_progress projects first, then planned
    @personal_projects = PersonalProject.in_progress.ordered.includes(:subjects).to_a +
                          PersonalProject.planned.ordered.includes(:subjects).to_a
  end
end
