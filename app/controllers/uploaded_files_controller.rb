
require 'servis_pdf/doc_pdf_ocr'
# метка очистки


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

  # def create
  #   @uploaded_file = @project.uploaded_files.build(file_params)
  #   @uploaded_file.name = file_params[:content].original_filename
  #
  #
  #   if @uploaded_file.save
  #     if file_params[:content].content_type != "application/pdf"
  #       flash[:danger] = "Файл без расширения PDF добавлен в проект.  Для него не будет доступно сравнение."
  #     else
  #       flash[:success] = 'Файл успешно добавлен в проект.'
  #     end
  #
  #     redirect_to edit_project_path(@project)
  #   else
  #     flash.now[:info] = 'Файл не был добавлен в проект.'
  #     render :new
  #   end
  # end


  def create
    file_extension = File.extname(file_params[:content].original_filename).downcase
    content_file = file_params[:content]

    if file_extension == ".pdf"
      file_path = content_file.path # Получаем путь к загруженному файлу

      obj = DocPdfOCR.new(file_path) # Создаем экземпляр класса DocPdfOCR

      if obj.create_pdf_with_ocr == false # Проверяем результат создания PDF с распознанным текстом
        @uploaded_file = @project.uploaded_files.build(content: content_file) # Создаем экземпляр UploadedFile с исходным загруженным файлом
      else
        converted_pdf_path = obj.create_pdf_with_ocr # Получаем путь к обработанному PDF
        content_blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(converted_pdf_path),
          filename: File.basename(converted_pdf_path),
          content_type: "application/pdf"
        )
        @uploaded_file = @project.uploaded_files.build(content: content_blob) # Создаем экземпляр UploadedFile с обработанным файлом
      end
    else
      @uploaded_file = @project.uploaded_files.build(content: content_file) # Создаем экземпляр UploadedFile с исходным загруженным файлом
    end

    @uploaded_file.name = content_file.original_filename

    if @uploaded_file.save

      if file_extension == ".pdf" && obj.create_pdf_with_ocr != false
        flash[:success] = 'Файл успешно добавлен в проект. Загружен файл с распознанным текстом.'
      else
        flash[:success] = 'Файл успешно добавлен в проект.'
      end

      DocPdfOCR.remove_files_from_dir
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
