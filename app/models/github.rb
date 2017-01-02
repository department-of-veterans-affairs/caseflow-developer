class Github
  GITHUB_TEAM_IDS = {
    APPEALS_PM: 2221656,
    CASEFLOW: 2221658
  }

  attr_accessor :team_members, :team_repos


  def get_issues(team_name, *labels)
    geat_team_info(team_name)

    @team_repos.map do |repo|
      Octokit.list_issues(repo[:full_name], labels: labels.join(','))
    end.flatten
  end

  def issues_by_assignee(team_name, *labels)
    grouped_issues = get_issues(team_name,labels).group_by do |issue|
      issue[:assignee] =  {login: "Unassigned"} if issue[:assignee].nil?
      issue[:assignee][:login]
    end

    # Full Name is not available w/o a call to Octokit.user(), expensive ~3secs
    grouped_issues.transform_keys do |key|
      Octokit.user(key)[:name]
    end
  end

  private

  def geat_team_info(team_name)
    team_ids = if team_name.nil?
      GITHUB_TEAM_IDS.values
    else
      GITHUB_TEAM_IDS.values_at(team_name.to_sym)
    end

    @team_members = team_ids.map do |team_id|
      Octokit.team_members(team_id)
    end.flatten

    @team_repos = team_ids.map do |team_id|
      Octokit.team_repositories(team_id)
    end.flatten
  end
end

