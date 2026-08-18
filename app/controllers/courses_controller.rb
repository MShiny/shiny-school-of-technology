class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy ]

  def index
    @status_filter = params[:status] if Course.statuses.key?(params[:status])

    @courses = Course.ordered.includes(:subject)
    @courses = @courses.where(status: @status_filter) if @status_filter.present?
  end

  def show
  end

  def new
    @course = Course.new(subject_id: params[:subject_id])
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to @course, notice: "Course created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Course updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    subject = @course.subject
    @course.destroy
    redirect_to subject, notice: "Course deleted.", status: :see_other
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:subject_id, :title, :provider, :url, :status, :level, :purpose, :progress_percentage, :roadmap_position, :notes)
  end
end
