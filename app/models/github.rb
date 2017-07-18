class Github

  LABELS = ["Bug", "Feature Request", "Performance", "Training Request", "Discussion", "Test"]
  PRODUCT_LABELS = ["Dispatch", "eFolder", "Reader", "Certification", "Caseflow System"]
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

    # TODO This does not include PRs.
    @team_repos.map do |repo|
      query = <<-QUERY
        query($repo_owner: String!, $repo_name: String!, $state: IssueState!, $labels: [String!]!) { 
          repository(owner: $repo_owner, name: $repo_name) {
            issues(states: [$state], first: 100, labels: $labels) {
              nodes {
                assignees(first: 100) {
                  nodes {
                    login
                    name
                    avatarUrl
                  }
                }
                url
                title
                number
                author {
                  login
                }
                labels(first: 100) {
                  nodes {
                    color
                    name
                  }
                }
              }
            }
          }
        }
      QUERY

      query_results = Graphql.query(query, {
        repo_owner: repo[:owner][:login],
        repo_name: repo[:name],
        state: state,
        labels: labels
      })

      query_results['repository']['issues']['nodes'].each do |issue|
        issue['repositoryName'] = repo[:name]
      end
    end.flatten
  end

  def is_issue_unassigned(issue)
    issue['assignees']['nodes'].empty?
  end

  def issues_by_assignee(team_name, *labels)
    issues = get_issues(team_name, 'OPEN', *labels)
    Rails.logger.info issues
    filtered_issues = issues.reject do |issue| 
      issue['repositoryName'] == "appeals-support" || (is_issue_unassigned(issue) && issue['title'] =~ /wip/i)
    end

    # TODO: this will make issues only show up under the first person to whom the issue is assigned.
    # We would like the issue to show up under each person to whom it is assigned.
    filtered_issues.group_by do |issue|
      if is_issue_unassigned(issue) then 'unassigned' else issue['assignees']['nodes'].first['login'] end
    end
  end


  #BVA Technologies
  def get_bva_issues()
    issues = Octokit.list_issues("department-of-veterans-affairs/bva-technology", direction: 'desc')
    filtered_issues = issues.select { |i| i[:state] =='open'}
    grouped_issues = filtered_issues.group_by do |issue|
      issue[:assignee] =  {login: "Unassigned"} if issue[:assignee].nil?
      issue[:assignee][:login]
    end

    #Full Name is not available w/o a call to Octokit.user(), expensive ~3secs
    grouped_issues.transform_keys do |key|
      Octokit.user(key)[:name] || key
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

  def get_sprint_issues(repos, date_since, date_until)
    Octokit.auto_paginate = true
    @issues = []
    repos.each do |repo_name|
      @issues.concat(Octokit.list_issues(
        repo_name.to_s,
        since: date_since.to_s,
        sort: 'updated',
        direction: 'desc',
        state: 'all'))
    end
    return @issues
  end

  def get_events_for_issue(iss)
    Octokit.issue_events("#{iss[:url].split("\/")[4]}/#{iss[:url].split("\/")[5]}", iss[:number])
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
