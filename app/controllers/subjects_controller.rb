class SubjectsController < ApplicationController
  before_action :set_subject, only: %i[ show edit update destroy ]

  def index
    @subjects = Subject.ordered.includes(:degrees)
  end

  def show
    @courses = @subject.courses.ordered
    @in_progress_courses = @subject.courses.in_progress.ordered
    @degrees = @subject.degrees.ordered
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
