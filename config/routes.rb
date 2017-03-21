Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  get "/sprint/standup" => "sprint#standup"
  get "/sprint/issues_report" => "sprint#issues_report"
  get "/sprint/weekly_report" => "sprint#weekly_report"
  get "/sprint/weekly_report" => "sprint#index"
  
  root "sprint#standup"
  
end
