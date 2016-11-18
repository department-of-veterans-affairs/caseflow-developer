Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get "/sprint/standup" => "sprint#standup"
  get "/sprint/closed_issues" => "sprint#closed_issues"
  
  root "sprint#standup"
end
