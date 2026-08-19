class SubjectsController < ApplicationController
  before_action :set_subject, only: %i[ show edit update destroy ]

  def index
    @subjects = Subject.ordered.includes(:degrees, :courses)
  end

  def show
    @current_courses = @subject.courses.in_progress.roadmap_ordered
    @next_up_courses = @subject.courses.planned.roadmap_ordered
    @completed_courses = @subject.courses.completed.roadmap_ordered
    @other_courses = @subject.courses.where(status: %w[ paused dropped ]).roadmap_ordered
    @degrees = @subject.degrees.ordered
    @personal_projects = @subject.personal_projects.ordered
  end

  def new
    @subject = Subject.new
  end

  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      redirect_to @subject, notice: "Subject created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @subject.update(subject_params)
      redirect_to @subject, notice: "Subject updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subject.destroy
    redirect_to subjects_path, notice: "Subject deleted.", status: :see_other
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :description, :status, :notes, degree_ids: [])
  end
end
