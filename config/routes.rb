Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get "/sprint" => "sprint#index"
  get "/sprint/backlog" => "sprint#backlog"

  get "/sign_in" => "sign_in#index"
  
  root "sprint#index"
end
