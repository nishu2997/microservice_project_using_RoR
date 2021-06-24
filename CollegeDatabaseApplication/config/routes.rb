Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "home#index"
  resources :departments
  resources :students do
    resources :enrolls
  end
  resources :courses
end
