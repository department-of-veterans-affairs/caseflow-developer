class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource_or_scope)
    Octokit.configure do |c|
      c.auto_paginate = true
      c.access_token = current_user.github_access_token
    end
    sprint_standup_path
  end
end
