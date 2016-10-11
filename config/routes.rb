Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }



  get "/sprint" => "sprint#index"

  root "sign_in#index"

  
end
