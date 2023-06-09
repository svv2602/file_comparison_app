# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :users do
    patch 'update_role', on: :member
  end
  resources :projects do
    resources :uploaded_files, as: 'files' do
      member do
        get 'edit_text_content' # Новый маршрут для редактирования текстового содержимого
        patch 'update_text_content' # Маршрут для обновления текстового содержимого
        post 'upload_file_content' # маршрут для загрузки оригинального файла
        post 'create_pdf'
      end
    end
    get 'compare_form', to: 'projects#compare_form', on: :member
    get 'compare_new_results', to: 'projects#compare_new_results', on: :member

    post 'compare', on: :member
  end

  root "projects#index"

end
