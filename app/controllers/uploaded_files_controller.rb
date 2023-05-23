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
      if file_params[:content].content_type != "application/pdf"
        flash[:danger] = "Файл без расширения PDF добавлен в проект.  Для него не будет доступно сравнение."
      else
        flash[:success] = 'Файл успешно добавлен в проект.'
      end

      redirect_to edit_project_path(@project)
    else
      flash.now[:info] = 'Файл не был добавлен в проект.'
      render :new
    end
  end

  def destroy
    @uploaded_file.destroy
    flash[:success] = 'Файл был успешно удален из проекта.'
    redirect_to edit_project_path(@project)
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
