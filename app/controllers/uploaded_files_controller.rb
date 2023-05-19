class UploadedFilesController < ApplicationController
  before_action :set_project
  before_action :set_file, only: [:show, :destroy]

  def index
    @uploaded_files = @project.uploaded_files
  end

  def show
  end

  def new
    @uploaded_file = @project.uploaded_files.build
  end

  def create
    @uploaded_file = @project.uploaded_files.build(file_params)
    @uploaded_file.name = file_params[:content].original_filename
    if @uploaded_file.save
      redirect_to project_files_path(@project), notice: 'File was successfully uploaded.'
    else
      render :new
    end
  end

  def destroy
    @uploaded_file.destroy
    redirect_to edit_project_path(@project), notice: 'File was successfully destroyed.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_file
    @uploaded_file = @project.uploaded_files.find(params[:id])
  end

  def file_params
    params.require(:uploaded_file).permit(:content)
  end
end
