Rails.application.routes.draw do
  post 'session_controller/authenticate'

  get 'session_controller/destroy'

  get 'application/current_us'

  devise_for :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
