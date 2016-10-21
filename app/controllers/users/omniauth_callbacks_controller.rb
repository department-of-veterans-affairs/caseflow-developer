# 2008080 DS Appeals
# 2129396 NAVA
# 1827228 Appeals PM

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    if check_team_membership(2008080) || check_team_membership(2129396) || check_team_membership(1827228)
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in_and_redirect @user
    else
      redirect_to root_path
    end
  end

  private 

  def check_team_membership(id)
    Octokit.team_member?(2008080, request.env["omniauth.auth"].extra.raw_info.login)
  end

end

