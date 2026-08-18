class PersonalProjectsController < ApplicationController
  before_action :set_personal_project, only: %i[ show edit update destroy ]

  def index
    @personal_projects = PersonalProject.ordered.includes(:subjects)
  end

  def show
    @subjects = @personal_project.subjects.ordered
  end

  def new
    @personal_project = PersonalProject.new
  end

  def create
    @personal_project = PersonalProject.new(personal_project_params)

    if @personal_project.save
      redirect_to @personal_project, notice: "Personal project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @personal_project.update(personal_project_params)
      redirect_to @personal_project, notice: "Personal project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @personal_project.destroy
    redirect_to personal_projects_path, notice: "Personal project deleted.", status: :see_other
  end

  private

  def set_personal_project
    @personal_project = PersonalProject.find(params[:id])
  end

  def personal_project_params
    params.require(:personal_project).permit(:name, :description, :status, :goal, :target_date, :notes, subject_ids: [])
  end
end
