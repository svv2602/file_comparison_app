
require 'servis_pdf/doc_pdf_ocr'
require 'servis_pdf/text_processing'
# метка очистки


class UploadedFilesController < ApplicationController
  include TextProcessing
  before_action :set_project
  before_action :set_file, only: [:show, :destroy,:create_pdf,
                                  :edit_text_content,
                                  :update_text_content,
                                  :upload_file_content]

  def index
    @uploaded_files = @project.uploaded_files
  end

  def show
  end

  def new
    @uploaded_file = @project.uploaded_files.build
  end

  def edit_text_content
    # @uploaded_file = UploadedFile.find(params[:id])
  end

  def update_text_content
    # @uploaded_file = UploadedFile.find(params[:id])
    if @uploaded_file.update(text_content: params[:uploaded_file][:text_content])
      flash[:success] = 'Текст успешно обновлен.'
      redirect_to project_path(@uploaded_file.project)
    else
      flash.now[:info] = 'Ошибка при обновлении текста.'
      render :edit_text_content
    end
  end


  def create
    file_extension = File.extname(file_params[:content].original_filename).downcase
    content_file = file_params[:content]


    if file_extension == ".pdf"
      file_path = content_file.path # Получаем путь к загруженному файлу
      obj = DocPdfOCR.new(file_path, current_user.id) # Создаем экземпляр класса DocPdfOCR

      if obj.create_pdf_with_ocr == false # Проверяем результат создания PDF с распознанным текстом
        @uploaded_file = @project.uploaded_files.build(content: content_file, processed_file: content_file)
      else
        converted_pdf_path = obj.create_pdf_with_ocr # Получаем путь к обработанному PDF
        processed_file_blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(converted_pdf_path),
          filename: File.basename(converted_pdf_path),
          content_type: "application/pdf"
        )

        @uploaded_file = @project.uploaded_files.build(content: content_file, processed_file: processed_file_blob) # Создаем экземпляр UploadedFile с обработанным файлом
      end

    else
      @uploaded_file = @project.uploaded_files.build(content: content_file) # Создаем экземпляр UploadedFile с исходным загруженным файлом
    end

    @uploaded_file.name = content_file.original_filename
    #============================
    load_file_content
    #================================
    if @uploaded_file.save

      if file_extension == ".pdf" && obj.create_pdf_with_ocr != false
        flash[:success] = 'Файл успешно добавлен в проект. Загружен файл с распознанным текстом.'
      else
        flash[:success] = 'Файл успешно добавлен в проект.'
      end


      DocPdfOCR.remove_files_from_dir(current_user.id)

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

  def create_pdf
    create_pdf_from_text(@uploaded_file)
    redirect_to edit_project_path(@project), notice: 'PDF успешно обновлен.'
  end

  def upload_file_content
    load_file_content
    @uploaded_file.save

    redirect_to edit_text_content_project_file_path(@uploaded_file.project, @uploaded_file), notice: 'Оригинальный файл успешно загружен.'
  end

  private

  def load_file_content
    file_content = @uploaded_file.processed_file.download
    @uploaded_file.text_content = extract_text(file_content)
  end


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
