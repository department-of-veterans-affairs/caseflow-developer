class Github

  LABELS = ["Bug", "Feature Request", "Performance", "Training Request", "Discussion", "Test"]
  PRODUCT_LABELS = ["Dispatch", "eFolder", "Reader", "Certification", "Caseflow System"]
  REPORT_LABELS = ["NSD", "Source - Feedback","DSVA Member","Phone"]
  RESOLUTION_LABELS =["Resolution Team - Tier 2", "Resolution Team - Tier 3", "Resolution Team - Training"]
  STATE_LABELS = ["In-Progress", "In Progress", "Blocked", "Closed"]
  
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
                createdAt
              }
            }
            issues(first: 100, states: [$state], labels: $labels) {
              edges {
                node {
                  ...assignableFields
                  ...commentFields
                  ...labelFields
                  number
                  title
                  url
                  timeline(last: 100) {
                    nodes { 
                      __typename
                      ... on LabeledEvent {
                        createdAt
                        label {
                          name
                        }
                        actor {
                          login
                        }
                      }
                    }
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

      def annotate_work_items!(items, type, repo)
        items.each do |item|
          item['repositoryName'] = repo[:name]
          item['type'] = type

          entered_current_state_time = nil

          if repo[:name] != 'appeals-design-research'
            if type == :issue
              is_discussion_issue = item['labels']['nodes'].any? do |label|
                label['name'] == 'discussion'
              end
              
              unless is_discussion_issue
                # If an issue has been in and out of "In Progress" or "In Validation" multiple times,
                # we'll just take the most recent time.
                entered_current_state_time = item['timeline']['nodes'].find_all do |event|
                  event['__typename'] == 'LabeledEvent' && 
                    ['In-Validation', 'In Validation', 'In-Progress', 'In Progress'].include?(event['label']['name'])
                end.map do |event|
                  event['createdAt']
                end.max
              end
            elsif type == :pull_request
              entered_current_state_time = item['createdAt']
            end

            if entered_current_state_time
              days_in_current_state = DateTime.parse(entered_current_state_time).business_days_until(DateTime.now).to_i

              if days_in_current_state <= 4
                norm = 'norm-good'
              elsif days_in_current_state <= 6
                norm = 'norm-mediocre'
              else
                norm = 'norm-dangerous'
              end

              item['timing'] = {
                'enteredCurrentStateTime' => entered_current_state_time,
                'durationMessage' => time_ago_in_words(DateTime.now - days_in_current_state),
                'norm' => norm
              }
            end
          end
        end
      end

      # We're wrapping the issues query in edges instead of accessing nodes directly because it's
      # a workaround for a GH bug: https://twitter.com/nickheiner/status/887392169144852481.
      issues = query_results['repository']['issues']['edges'].map do |edge|
        edge['node']
      end

      annotate_work_items!(issues, :issue, repo)
        .concat(annotate_work_items!(query_results['repository']['pullRequests']['nodes'], :pull_request, repo))
        .sort_by do |work_item|
          if work_item['timing']
            work_item['timing']['enteredCurrentStateTime']
          else 
            # If an item does not have a timing, we'll put it at the end.
            '2100'
          end
        end
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
    get_issues_for_repo({
        :owner => {
          :login => 'department-of-veterans-affairs'
        },
        :name => 'appeals-support'
      }, 
      "OPEN", 
      "In-Progress",
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
    Rails.logger.debug "Getting team info for '#{team_name}'"
    team_ids = if team_name.nil?
      GITHUB_TEAM_IDS.values
    else
      GITHUB_TEAM_IDS.values_at(team_name.to_sym)
    end

    @team_members = team_ids.map do |team_id|
      Rails.logger.debug "Getting team members for #{team_id}"
      Octokit.team_members(team_id)
    end.flatten
    
    @team_repos = team_ids.map do |team_id|
      Rails.logger.debug "Getting team repos for #{team_id}"
      Octokit.team_repositories(team_id)
    end.flatten
  end
end
