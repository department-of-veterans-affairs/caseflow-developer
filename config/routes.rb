Rails.application.routes.draw do
  root "sprint#index"

  get "/sprint/backlog" => "sprint#backlog"
end
