class DefaultGoalItemsController < ApplicationController
  before_action :set_default_goal_item, only: %i[ edit update destroy toggle_active ]

  def index
    @default_goal_items = DefaultGoalItem.ordered
    @default_goal_item = DefaultGoalItem.new
  end

  def new
    @default_goal_item = DefaultGoalItem.new
  end

  def create
    @default_goal_item = DefaultGoalItem.new(default_goal_item_params)

    if @default_goal_item.save
      redirect_to default_goal_items_path, notice: "Default goal item added."
    else
      @default_goal_items = DefaultGoalItem.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @default_goal_item.update(default_goal_item_params)
      redirect_to default_goal_items_path, notice: "Default goal item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_active
    @default_goal_item.update!(active: !@default_goal_item.active)
    redirect_to default_goal_items_path, notice: @default_goal_item.active? ? "Item activated." : "Item deactivated."
  end

  def destroy
    @default_goal_item.destroy
    redirect_to default_goal_items_path, notice: "Default goal item removed.", status: :see_other
  end

  private

  def set_default_goal_item
    @default_goal_item = DefaultGoalItem.find(params[:id])
  end

  def default_goal_item_params
    params.require(:default_goal_item).permit(:text, :position, :active, :daily, weekdays: [])
  end
end
