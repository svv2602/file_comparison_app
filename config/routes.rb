# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :projects do
    resources :uploaded_files, as: 'files'
    post 'compare', on: :member
  end

  # get 'documents/new'
  # get 'documents/download_pdf', to: 'documents#download_pdf', as: 'download_pdf'
  # post 'documents/process_pdf'

  root "projects#index"

end
