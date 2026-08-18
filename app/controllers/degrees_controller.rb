class DegreesController < ApplicationController
  before_action :set_degree, only: %i[ show edit update destroy ]

  def index
    @degrees = Degree.ordered.includes(:subjects)
  end

  def show
    @subjects = @degree.subjects.ordered
  end

  def new
    @degree = Degree.new
  end

  def create
    @degree = Degree.new(degree_params)

    if @degree.save
      redirect_to @degree, notice: "Degree created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @degree.update(degree_params)
      redirect_to @degree, notice: "Degree updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @degree.destroy
    redirect_to degrees_path, notice: "Degree deleted.", status: :see_other
  end

  private

  def set_degree
    @degree = Degree.find(params[:id])
  end

  def degree_params
    params.require(:degree).permit(:name, :description, :status, subject_ids: [])
  end
end
