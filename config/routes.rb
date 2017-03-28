Rails.application.routes.draw do
	
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  get "/sprint/standup" => "sprint#standup"
  get "/sprint/issues_report" => "sprint#issues_report"
  get "/sprint/weekly_report" => "sprint#weekly_report"
  get "/sprint/incident_report" => "sprint#incident_report"
 get 'reports', to:'reports#weekly_report'
  root "sprint#standup"
  
end
