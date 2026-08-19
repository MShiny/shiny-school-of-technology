class DailyGoalItemsController < ApplicationController
  before_action :set_daily_goal_item, only: %i[ update destroy toggle ]
  before_action :set_daily_goal_for_create, only: %i[ create ]
  before_action :ensure_today!, only: %i[ create update destroy toggle ]

  def create
    item = @daily_goal.daily_goal_items.build(item_params)
    item.position = (@daily_goal.daily_goal_items.maximum(:position) || 0) + 1

    if item.save
      redirect_back fallback_location: daily_goal_path(@daily_goal), notice: "Item added."
    else
      redirect_back fallback_location: daily_goal_path(@daily_goal), alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    if @daily_goal_item.update(item_params)
      redirect_back fallback_location: daily_goal_path(@daily_goal_item.daily_goal), notice: "Item updated."
    else
      redirect_back fallback_location: daily_goal_path(@daily_goal_item.daily_goal), alert: @daily_goal_item.errors.full_messages.to_sentence
    end
  end

  def toggle
    @daily_goal_item.update!(completed: !@daily_goal_item.completed)
    redirect_back fallback_location: daily_goal_path(@daily_goal_item.daily_goal)
  end

  def destroy
    goal = @daily_goal_item.daily_goal
    @daily_goal_item.destroy
    redirect_back fallback_location: daily_goal_path(goal), notice: "Item removed."
  end

  private

  def set_daily_goal_item
    @daily_goal_item = DailyGoalItem.find(params[:id])
  end

  def set_daily_goal_for_create
    @daily_goal = DailyGoal.find(params.require(:daily_goal_item)[:daily_goal_id])
  end

  # Today's checklist is the only one that can be customized. Historical
  # checklists are kept as an accurate snapshot of what actually happened.
  def ensure_today!
    goal = @daily_goal || @daily_goal_item.daily_goal
    return if goal.date == Date.current

    redirect_back fallback_location: daily_goal_path(goal), alert: "Only today's checklist can be edited."
  end

  def item_params
    params.require(:daily_goal_item).permit(:text, :completed)
  end
end
