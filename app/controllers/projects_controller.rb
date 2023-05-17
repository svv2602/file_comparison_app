require 'servis_pdf/pdf_processor'

class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy, :compare]

  # GET /projects
  def index
    @projects = current_user.projects
  end

  # GET /projects/1
  def show
    # @results = ""
  end

  # GET /projects/new
  def new
    @project = current_user.projects.build
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = current_user.projects.build(project_params)

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  def compare
    # Извлечь файлы из проекта по их ID

    pdf_blob1 = ActiveStorage::Blob.find(params[:file1_id])
    file1 = PdfProcessor.new(pdf_blob1.id)
    pdf_blob2 = ActiveStorage::Blob.find(params[:file2_id])
    file2 = PdfProcessor.new(pdf_blob2.id)

    @results = PdfProcessor.match_result(file1, file2)
    puts @results
    # Отображать результаты в представлении compare
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.append("results", partial: "projects/compare_results", locals: { results: @results }) }
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = current_user.projects.find(params[:id])
    redirect_to root_path unless @project.user == current_user
    # raise ActiveRecord::RecordNotFound unless @project.user == current_user
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.require(:project).permit(:name, files: [])
  end


end

