class Github
  GITHUB_TEAM_IDS = {
    APPEALS_PM: 2221656,
    CASEFLOW: 2221658
  }

  attr_accessor :repo_names

  def initialize
    @repo_names = []
  end

  def get_issues(team_name, *labels)
    team_ids = if team_name.nil?
      GITHUB_TEAM_IDS.values
    else
      GITHUB_TEAM_IDS.values_at(team_name.to_sym)
    end

    get_team_repos(team_ids).map do |repo|
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

  def get_team_repos(team_ids)
    team_ids.map do |team_id|
      team_repos = Octokit.team_repositories(team_id)
      @repo_names.concat team_repos
      team_repos
    end.flatten
  end
end

