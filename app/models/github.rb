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

  def get_issues(*args)
    work_items = get_work_items(*args)
    work_items.find_all do |work_item|
      work_item['type'] == :issue
    end
  end

  def get_issues_for_repo(repo, state, *labels)
    query = <<-QUERY
        fragment assignableFields on Assignable {
          assignees(first: 100) {
            nodes {
              login
              name
              avatarUrl
            }
          }
        }
        fragment commentFields on Comment {
          author {
            login
          }
        }
        fragment labelFields on Labelable {
          labels(first: 100) {
            nodes {
              color
              name
            }
          }  
        }
        query($repo_owner: String!, $repo_name: String!, $state: IssueState!, $labels: [String!]!) { 
          repository(owner: $repo_owner, name: $repo_name) {
            pullRequests(first: 100, states: OPEN, labels: $labels) {
              nodes {
                ...assignableFields
                ...commentFields
                ...labelFields
                number
                title
                url
              }
            }
            issues(first: 100, states: [$state], labels: $labels) {
              nodes {
                ...assignableFields
                ...commentFields
                ...labelFields
                number
                title
                url
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

      def add_repo_name_and_type(items, type, repo)
        items.each do |item|
          item['repositoryName'] = repo[:name]
          item['type'] = type
        end
      end

      add_repo_name_and_type(query_results['repository']['issues']['nodes'], :issue, repo)
        .concat(add_repo_name_and_type(query_results['repository']['pullRequests']['nodes'], :pull_request, repo))
  end

  # I think it's confusing to refer to both PRs and issues as "issues". 
  # Changing most instances of "issues" to be "work_items" is too much
  # churn for this PR.
  def get_work_items(team_name, state, *labels)
    get_team_info(team_name)

    # TODO This does not include PRs.
    @team_repos.map do |repo|
      get_issues_for_repo(repo, state, *labels)
    end.flatten
  end

  def is_issue_unassigned(issue)
    issue['assignees']['nodes'].empty?
  end

  def issues_by_assignee(team_name, *labels)
    issues = get_work_items(team_name, 'OPEN', *labels)
    filtered_issues = issues.reject do |issue| 
      issue['repositoryName'] == "appeals-support" || 
        (issue['type'] == :pull_request && is_issue_unassigned(issue) && issue['title'] =~ /wip/i)
    end

    # This is certainly not the most algorithmically efficient way to do this, but the data set is 
    # small enough that it doesn't make a difference.

    assignees = filtered_issues.map do |issue|
      issue['assignees']['nodes']
    end.flatten.uniq do |assignee|
      assignee['login']
    end.map do |assignee|
      [assignee['login'], assignee]
    end.push(['unassigned', {
      'login' => 'unassigned',
      'name' => 'Unassigned'
    }]).to_h

    # TODO: this will make issues only show up under the first person to whom the issue is assigned.
    # We would like the issue to show up under each person to whom it is assigned.
    issues_by_assignee = assignees.transform_values do |assignee|
      filtered_issues.find_all do |issue|
        if assignee['login'] == 'unassigned'
          next is_issue_unassigned(issue)
        end

        issue['assignees']['nodes'].any? do |assignee_node|
          assignee['login'] == assignee_node['login']
        end
      end
    end

    [issues_by_assignee, assignees]
  end

  def get_product_support_issues
    get_issues_for_repo({
        :owner => {
          :login => 'department-of-veterans-affairs'
        },
        :name => 'appeals-support'
      }, 
      "OPEN", 
      "In Progress"
    )
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
