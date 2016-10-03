Octokit.configure do |c|
  c.access_token = Rails.application.secrets.github_access_key
end