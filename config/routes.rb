# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :projects do
    resources :uploaded_files, as: 'files'
    post 'compare', on: :member
  end

  root "projects#index"

end
