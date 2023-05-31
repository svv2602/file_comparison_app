require 'servis_pdf/pdf_processor'

class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy, :compare_new_results,
                                     :compare, :destroy_file, :compare_form]

  # GET /projects
  def index
    @projects = current_user.projects

    if params[:search].present?
      search_query = params[:search].downcase
      @projects = @projects.where("LOWER(name) LIKE ? OR LOWER(comment) LIKE ?", "%#{search_query}%", "%#{search_query}%")
    end

    @projects = @projects.order(created_at: :desc)

    @pagy, @projects = pagy(@projects)
    @show_pagination = @projects.count > @pagy.items
  end

  # GET /projects/1
  def show
    # @results = ""
    session[:compare_params] = {}
  end

  # GET /projects/new
  def new
    @project = current_user.projects.build
  end

  # GET /projects/1/edit
  def edit

  end

  def compare_form
    @uploaded_files = @project.uploaded_files
    # Загрузить сохраненные параметры из сеанса
    session[:compare_params] = {} if params[:source] == 'show'
    @compare_params = session[:compare_params] || {}
    @file_options = @uploaded_files.map { |uf| [uf.name, uf.id] }
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
    @project.uploaded_files.destroy_all # Удаление связанных файлов
    @project.destroy
    flash[:success] = 'Проект успешно удален.'
    redirect_to projects_url
  end

  def compare
    set_session_data
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
        percent = params[:percent].to_i
        pdf_processor1 = PdfProcessor.new(file1.processed_file, start_line1, end_line1)
        pdf_processor2 = PdfProcessor.new(file2.processed_file, start_line2, end_line2)

        if pdf_processor1.contains_text? && pdf_processor2.contains_text?
          @results = PdfProcessor.match_result(pdf_processor1, pdf_processor2, percent)
          @@result_temp = @results
          # Сохранить выбранные параметры в сеанс
          # respond_to do |format|
          #   format.turbo_stream { render turbo_stream: turbo_stream.append("results", partial: "projects/compare_results", locals: { results: @results }) }
          # end
          redirect_to compare_new_results_project_path(@project)
        else
          flash[:warning] = find_error_files(pdf_processor1, pdf_processor2)
          redirect_to compare_form_project_path(@project)
        end
      else
        # flash.clear
        flash[:warning] = "Пожалуйста, выберите файлы для сравнения"
        redirect_to compare_form_project_path(@project)
      end

    rescue ArgumentError => e
      flash.clear
      flash[:danger] = e.message
      redirect_to compare_form_project_path(@project)
      return
    end

  end

  def compare_new_results
    # Возможно, вам потребуется получить необходимые данные для отображения результатов сравнения
    @results = @@result_temp

    @name_file1 = UploadedFile.find(session[:compare_params]["file1_id"])
    @name_file2 = UploadedFile.find(session[:compare_params]["file2_id"])

  end

  private

  def set_session_data
    session[:compare_params] = {
      file1_id: params[:file1_id],
      start_line1: params[:start_line1],
      end_line1: params[:end_line1],
      file2_id: params[:file2_id],
      start_line2: params[:start_line2],
      end_line2: params[:end_line2],
      percent: params[:percent]
    }
  end

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

