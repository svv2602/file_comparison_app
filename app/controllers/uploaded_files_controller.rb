class UploadedFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_uploaded_file, only: [:show, :edit, :update, :destroy]

  # GET /projects/1/uploaded_files
  def index
    @uploaded_files = @project.uploaded_files
  end

  # GET /projects/1/uploaded_files/1
  def show
  end

  # GET /projects/1/uploaded_files/new
  def new
    @uploaded_file = @project.uploaded_files.build
  end

  # GET /projects/1/uploaded_files/1/edit
  def edit
  end

  # POST /projects/1/uploaded_files
  def create
    @uploaded_file = @project.uploaded_files.build(uploaded_file_params)

    if @uploaded_file.save
      redirect_to [@project, @uploaded_file], notice: 'File was successfully uploaded.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1/uploaded_files/1
  def update
    if @uploaded_file.update(uploaded_file_params)
      redirect_to [@project, @uploaded_file], notice: 'File was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1/uploaded_files/1
  def destroy
    @uploaded_file.destroy
    redirect_to project_uploaded_files_url(@project), notice: 'File was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_uploaded_file
    @uploaded_file = @project.uploaded_files.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def uploaded_file_params
    params.require(:uploaded_file).permit(:file)
  end
end
