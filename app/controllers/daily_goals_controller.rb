class DailyGoalsController < ApplicationController
  before_action :set_daily_goal, only: %i[ show edit update mark_met mark_not_met reset ]

  def index
    @daily_goals = DailyGoal.recent
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

  def mark_met
    @daily_goal.update!(status: "met")
    redirect_back fallback_location: daily_goal_path(@daily_goal), notice: "Marked as met."
  end

  def mark_not_met
    @daily_goal.update!(status: "not_met")
    redirect_back fallback_location: daily_goal_path(@daily_goal), notice: "Marked as not met."
  end

  def reset
    @daily_goal.update!(status: "pending")
    redirect_back fallback_location: daily_goal_path(@daily_goal), notice: "Reset to pending."
  end

  private

  def set_daily_goal
    @daily_goal = DailyGoal.find(params[:id])
  end

  def daily_goal_params
    params.require(:daily_goal).permit(:goal_text, :status, :notes)
  end
end
