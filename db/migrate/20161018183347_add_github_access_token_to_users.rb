class AddGithubAccessTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :github_access_token, :string
  end
end
