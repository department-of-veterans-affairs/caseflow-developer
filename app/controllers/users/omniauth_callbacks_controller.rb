# 2008080 DS Appeals
# 2129396 NAVA

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    if Octokit.team_member?(2008080, request.env["omniauth.auth"].extra.raw_info.login) || Octokit.team_member?(2129396, request.env["omniauth.auth"].extra.raw_info.login)
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in_and_redirect @user
    else
      redirect_to root_path
    end
  end
end

