Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get "/sprint/standup" => "sprint#standup"
  get "/sprint/backlog" => "sprint#backlog"
  
  root "sprint#standup"
end
