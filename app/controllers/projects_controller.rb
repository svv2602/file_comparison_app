require 'servis_pdf/pdf_processor'

class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy, :compare, :destroy_file]

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
      flash[:success] = 'Проект успешно обновлен.'
      redirect_to @project
    else
      flash.now[:warning] = 'Ошибка при создании проекта.'
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      flash[:success] = 'Проект успешно обновлен.'
      redirect_to @project
    else
      flash.now[:warning] = 'Ошибка при обновлении проекта.'
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Проект успешно удален.'
  end

  def compare

    begin
      @results = nil
      # Извлечь файлы из проекта по их ID
      if params[:file1_id].present? && params[:file2_id].present?

        file1 = UploadedFile.find(params[:file1_id])
        file2 = UploadedFile.find(params[:file2_id])
        start_line1 = params[:start_line1]
        end_line1 = params[:end_line1]
        start_line2 = params[:start_line2]
        end_line2 = params[:end_line2]
        pdf_processor1 = PdfProcessor.new(file1.content, start_line1, end_line1)
        pdf_processor2 = PdfProcessor.new(file2.content, start_line2, end_line2)

        if pdf_processor1.contains_text? && pdf_processor2.contains_text?
          @results = PdfProcessor.match_result(pdf_processor1, pdf_processor2)

          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.append("results", partial: "projects/compare_results", locals: { results: @results }) }
          end
        else
          flash[:danger] = find_error_files(pdf_processor1, pdf_processor2)
          redirect_to @project
        end
      else
        flash[:warning] = "Пожалуйста, выберите файлы для сравнения"
        redirect_to @project
      end

    rescue ArgumentError => e
      flash.clear
      flash[:danger] = e.message
      redirect_to @project
      return
    end


  end

  private

  def find_error_files(o1, o2)
    case
    when !o1.contains_text? && !o2.contains_text?
      txt = "Оба файла не содержат текстового контента."
    when !o1.contains_text? && o2.contains_text?
      txt = "Первый файл <#{o1.instance_variable_get(:@pdf_blob).record.name}>  не содержит текстового контента."
    when o1.contains_text? && !o2.contains_text?
      txt = "Второй файл <#{o2.instance_variable_get(:@pdf_blob).record.name}>  не содержит текстового контента."
    end
    txt
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = current_user.projects.find(params[:id])
    redirect_to root_path unless @project.user == current_user
    # raise ActiveRecord::RecordNotFound unless @project.user == current_user
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.require(:project).permit(:name, :comment, files: [])
  end

end

