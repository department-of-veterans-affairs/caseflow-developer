class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def after_sign_out_path_for(resource_or_scope)
    sign_in_path
  end

  def after_sign_in_path_for(resource_or_scope)
    root_path
  end


end
