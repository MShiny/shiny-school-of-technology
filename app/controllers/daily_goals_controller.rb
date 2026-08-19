class DailyGoalsController < ApplicationController
  before_action :set_daily_goal, only: %i[ show edit update ]

  def index
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
    @daily_goal = DailyGoal.find(params[:id])
  end

  def daily_goal_params
    params.require(:daily_goal).permit(:notes)
  end
end
