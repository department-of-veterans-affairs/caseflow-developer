class Github

  LABELS = ["Bug", "Feature Request", "Performance", "Training Request"]
  PRODUCT_LABELS = ["Dispatch", "eFolder", "eReader", "eReader", "Certification", "Caseflow System"]
  REPORT_LABELS = ["NSD", "Source - Feedback","DSVA Member","Phone"]
  RESOLUTION_LABELS =["Resolution Team - Tier 2", "Resolution Team - Tier 3", "Resolution Team - Training"]
  STATE_LABELS = ["In Progress", "Blocked", "Closed"]
  
  
  GITHUB_TEAM_IDS = {
    APPEALS_PM: 2221656,
    CASEFLOW: 2221658
  }

  attr_accessor :team_members, :team_repos


  def get_issues(team_name, state, *labels)
    get_team_info(team_name)

    @team_repos.map do |repo|
      Octokit.list_issues(repo[:full_name], state: state, labels: labels.join(','))
    end.flatten
  end

  def issues_by_assignee(team_name, *labels)
    issues = get_issues(team_name,'open', labels)
    filtered_issues = issues.reject { |i| i[:html_url].split("/")[4] == "appeals-support" }
    grouped_issues = filtered_issues.group_by do |issue|
      issue[:assignee] =  {login: "Unassigned"} if issue[:assignee].nil?
      issue[:assignee][:login]
    end

    # Full Name is not available w/o a call to Octokit.user(), expensive ~3secs
    grouped_issues.transform_keys do |key|
      Octokit.user(key)[:name]
    end
  end

  def get_product_support_issues
    Octokit.list_issues("department-of-veterans-affairs/appeals-support", state: "open", labels: "In Progress")
  end

   #Use hash to Keep issues created in past 7 days
  def get_all_support_issues
    response = Octokit.list_issues("department-of-veterans-affairs/appeals-support", direction: "asc", state: "all")
    response.keep_if { |v| v[:created_at] >= 7.days.ago }
  end 

   #Method to get the incident report
  def get_all_incident_issues
    response = Octokit.list_issues("department-of-veterans-affairs/appeals-support", direction: "asc", state: "open")
    response.reject { |v| v[:created_at] >= 10.days.ago }
  end 
  
  #Use hash to get all support issues 
  def get_all_master_issues
     Octokit.list_issues("department-of-veterans-affairs/appeals-support", direction: "asc", state: "all")
  end 

  private

  def get_team_info(team_name)
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

