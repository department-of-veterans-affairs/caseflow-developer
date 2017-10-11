class SprintController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!

  def handle_timeout_error
    begin
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout
      render 'timeout', :status => 500
    end
  end

  def standup
    handle_timeout_error do
      @ci = CI.new
      @github = Github.new 

      def sort_issues(issues, assignees) 
        issues.sort_by do |login, issues| 
          # '!' is a hack to move 'unassigned' to the front of the list.
          # There is a larger cleanup to do, but I don't want to make too many
          # changes right now. Also, I am not sure that Ruby hashes have
          # an iterating order as part of their contract, but in practice
          # it seems to work! :)
          if login == 'unassigned' then '!' else (assignees[login]['name'] || login) end
        end.to_h
      end

      Rails.logger.debug "Getting issues by assignee"
      in_progress_by_assignee_unsorted, @assignees = @github.issues_by_assignee(params[:team], "In-Progress", "In Progress", 'In Progress VACOLS', 'In Progress PMO')

      
      Rails.logger.debug "Sorting issues"
      @in_progress_by_assignee = sort_issues(in_progress_by_assignee_unsorted, @assignees)

      in_progress_by_assignee_optional_unsorted = []
      required_logins = @github.team_members.map {|i| i[:login] }
      @in_progress_by_assignee.each do |assignee, issues|
        next if assignee == 'unassigned'
        unless required_logins.include?(assignee)
          in_progress_by_assignee_optional_unsorted << [assignee, issues]
          @in_progress_by_assignee.delete(assignee)
        end
      end

      @in_progress_by_assignee_optional = sort_issues(in_progress_by_assignee_optional_unsorted, @assignees)

      @wip_limit = 3
      @wip_limit_issues_by_assignee = @in_progress_by_assignee.map do |assignee, issues|
        issue_count = issues.reject do |issue|
          issue['repositoryName'] == "appeals-design-research" || issue['type'] == :pull_request
        end.size
        if issue_count <= @wip_limit
          norm = 'norm-good'
        elsif issue_count <= @wip_limit * 2
          norm = 'norm-mediocre'
        else
          norm = 'norm-bad'
        end

        [
          assignee, 
          {
            :issue_count => issue_count,
            :norm => norm
          }
        ]
      end.to_h

      # TODO We shouldn't be doing two requests to each repo to get both 'In Progress' and in 'In Validation' tickets.
      # We should just make a single request and then do the sorting on this end. That should be much faster.
      Rails.logger.debug "Getting in-validation issues"
      @in_validation_issues = 
        @github.get_issues(params[:team], "OPEN", "In-Validation", "In Validation") if params[:team] == 'CASEFLOW'
      @product_support_issues = @github.get_product_support_issues if params[:team] == 'APPEALS_PM'
      
      # Removes optional assignees
      if params[:team] == "BVA_TECHNOLOGY"
        @in_progress_by_assignee_optional = []
      end
    end
  end

  
  def issues_report
    handle_timeout_error do
      @github = Github.new
      @issues_by_project = @github.get_issues('CASEFLOW', "CLOSED").group_by {|issue|  issue[:html_url].split("/")[4]}
    end
  end
  
  def weekly_report
    handle_timeout_error do
      @github = Github.new
      @weekly_report = @github.get_all_support_issues
      respond_to do |format|
        format.html
        format.xlsx {render xlsx: "report"}
      end
    end
  end
  
  def incident_report
    handle_timeout_error do
      @github = Github.new
      @incident_report = @github.get_all_incident_issues
      respond_to do |format|
        format.html
        format.xlsx {render xlsx: "incident_report"}
      end
    end
  end
  
  def master_report
    handle_timeout_error do
      @github = Github.new
      @master_report = @github.get_all_master_issues
      respond_to do |format|
        format.html
        format.xlsx {render xlsx: "master_report"}
      end
    end
  end

  def notes_report
    handle_timeout_error do
      @repos = [
        'department-of-veterans-affairs/caseflow',
        'department-of-veterans-affairs/caseflow-efolder',
        'department-of-veterans-affairs/caseflow-feedback',
        'department-of-veterans-affairs/caseflow-commons',
        'department-of-veterans-affairs/appeals-deployment'
      ]
      @github = Github.new

      # TODO The way we do this is hideously inefficient. Instead of fetching a bunch of issues
      # and then constructing a monsterous GraphQL query, we should just do one query
      # that has everything we need up-front.

      @date_since = params[:date_since]
      notes_issues = nil
      log_timing('get_github_issues') do
        notes_issues = @github.get_sprint_issues(@repos, @date_since, @date_until).select do |issue|
          issue[:html_url].include?("\/issues\/")
        end
      end
      
      $ISS_ARR = {}
      $ISS_STATUS = {"Triage" => "Triage",
                    "blocked" => "Blocked",
                    "validation-failed" => "Bugged",
                    "In-Progress" => "In-Progress",
                    "In Progress" => "In Progress",
                    "In-Validation" => "In-Validation",
                    "In Validation" => "In Validation",
                    "Current Sprint" => "Current Sprint"}
      $ISS_PRODUCT = {"caseflow-certification" => "Certification",
                      "caseflow-dispatch" => "Dispatch",
                      "styleguide" => "Styleguide",
                      "caseflow-feedback" => "Feedback",
                      "caseflow-reader" => "Reader",
                      "Discussion" => "Discussion"}
      $ISS_TEAM = {
        "whiskey" => "Whiskey",
        "tango" => "Tango",
        "foxtrot" => "Foxtrot",
        "omega" => "Omega"}
      $ISS_TYPE = {"bug" => "Bug",
                  "bug-ui" => "UI Bug",
                  "tech-improvement" => "Technical"}

      def sanitize_name_for_graphql(name) 
        name.gsub('-', '_')
      end

      def make_query_issue_key(issue)
        "issue#{issue[:number]}"
      end

      def make_repo_query_key(owner, repo_name)
        "repository_#{sanitize_name_for_graphql(owner)}_#{sanitize_name_for_graphql(repo_name)}"
      end

      # We need to create a mapping of events ahead of time,
      # rather than firing a query for every single issue.
      # We need to loop through the issues we found and
      # get a list of repo_owners and repo_names to go over.

      repo_query_parts = @repos.map do |slug|
        pairs = slug.split('/')
        owner = pairs[0]
        repo_name = pairs[1]

        issue_query_parts = notes_issues.select do |issue|
          issue[:repository_url].end_with?(slug)
        end.map do |issue|
          <<-QUERY
          #{make_query_issue_key(issue)}: issue(number: #{issue[:number]}) {
            timeline(last: 100) {
              nodes { 
                ... on LabeledEvent {
                  createdAt
                  label {
                    name
                  }
                }
              }
            }
          }
          QUERY
        end.join('')

        if issue_query_parts.length > 0
          <<-QUERY
          #{make_repo_query_key(owner, repo_name)}: repository(owner: "#{owner}", name: "#{repo_name}") {
            #{issue_query_parts}
          }            
          QUERY
        end
      end.join('')

      query = <<-QUERY
        query { 
          #{repo_query_parts}
        }
      QUERY
      
      all_issue_events = nil
      log_timing("graphql query for issues") do
        all_issue_events = Graphql.query(query)
      end

      notes_issues.each do |iss|
        iss_num = iss[:number]
        cur_issue = OpenStruct.new(title: nil,
        labels: [],
        close_date: nil,
        date_planned: nil,
        team: nil,
        link: nil,
        rel_prs: [],
        status: [],
        product: [])
        cur_issue.title = iss[:title]
        cur_issue.link = iss[:html_url]
        cur_issue.labels = iss[:labels].map { |lab| lab[:name] }
        
        # set status
        cur_issue.status = cur_issue.labels & $ISS_STATUS.keys
        cur_issue.status = cur_issue.status.map! { |status| $ISS_STATUS["#{status}"] }

        # set product
        cur_issue.product = cur_issue.labels & $ISS_PRODUCT.keys
        cur_issue.product = cur_issue.product.map! { |product| $ISS_PRODUCT["#{product}"] }
        cur_issue.product = ["eFolder"] if iss[:repository_url].split("\/")[-1] == "caseflow-efolder"
        cur_issue.product = ["Feedback"] if iss[:repository_url].split("\/")[-1] == "caseflow-feedback"
        cur_issue.product = ["Caseflow"] if cur_issue.product.empty?

        # set team
        cur_issue.team = cur_issue.labels & $ISS_TEAM.keys
        cur_issue.team = cur_issue.team.map! { |team| $ISS_TEAM["#{team}"] }
        cur_issue.team = ["Omega"] if iss[:repository_url].split("\/")[-1] == "appeals-deployment"
        cur_issue.team = ["Missing"] if cur_issue.team.empty?

        # set type
        cur_issue.type = cur_issue.labels & $ISS_TYPE.keys
        cur_issue.type = cur_issue.type.map! { |type| $ISS_TYPE["#{type}"] }
        cur_issue.type = ["Feature"] if cur_issue.type.empty?

        # set closed date
        if iss[:state] == "closed"
          cur_issue.status = ["Done"]
          cur_issue.close_date = iss[:updated_at].strftime("%-m/%-d/%Y")
        end
        cur_issue.status = ["New"] if cur_issue.status.empty?

        # get intake date
        repo_key = make_repo_query_key(iss[:repository_url].split("\/")[-2], iss[:repository_url].split("\/")[-1])
        issue_key = make_query_issue_key(iss)
        issue_events = all_issue_events[repo_key][issue_key]['timeline']['nodes'].reverse.select do |event|
          event.has_key?('label')
        end

        # TODO What is the logic for date_planned? What do we actually want?

        # GH API v4 and v3 produce different results here. In labeling events,
        # v3 shows the label name as it was at the time of the event. 
        # v4 shows the label name as it is at this moment. This means that switching
        # to v4 will produce different results than we've seen historically, since
        # some label names have changed over time.

        current_sprint_label_event = issue_events.detect do |event|
          event['label']['name'] == "Current-Sprint"
        end
        if current_sprint_label_event
          cur_issue.date_planned = Date.parse(current_sprint_label_event['createdAt']).strftime("%-m/%-d/%Y")
        else
          in_progress_label_event = issue_events.detect do |event|
            event['label']['name'] == "In-Progress" || event['label']['name'] == "In Progress" 
          end
          if in_progress_label_event
            cur_issue.date_planned = Date.parse(in_progress_label_event['createdAt']).strftime("%-m/%-d/%Y")
          end
        end
        if cur_issue.date_planned.nil? || cur_issue.status.include?("New")
          next
        end

        $ISS_ARR[iss_num] = cur_issue
      end

      respond_to do |format|
        format.html
        format.xlsx { render xlsx: "notes_report" }
      end
    end
  end
end
