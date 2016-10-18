class Github
  REPOS_URLS = [
    { name: "department-of-veterans-affairs/appeals-pm"},
    { name: "department-of-veterans-affairs/caseflow-certification"},
    { name: "department-of-veterans-affairs/caseflow-commons"},
    { name: "department-of-veterans-affairs/caseflow-dashboard"},
    { name: "department-of-veterans-affairs/appeals-deployment"},
    { name: "department-of-veterans-affairs/caseflow-efolder" }
  ]

  def initialize
    @all_issues = []
    REPOS_URLS.each do |repo|
      @all_issues.concat Octokit.list_issues(repo[:name])
    end
  end
    
  def in_progress_by_assignee
    issues = in_progress_issues
    assignees = assignees_from_issues(issues)

    # This adds a key => [] to store the issues
    assignees.each do |assignee|
      assignee[:issues] = []
    end
    assignees << { login: "Not Assigned", issues: [] }
    
    issues.each do |issue|
      if !issue[:assignee].nil?
        assignees.each do |assignee|
          if assignee[:login] == issue[:assignee][:login]
            assignee[:issues] << issue
          end
        end
      else
        assignees.each do |assignee|
          if assignee[:login] == "Not Assigned"
            assignee[:issues] << issue
          end
        end
      end
    end

    return assignees
  end

  def current_sprint_issues
    @all_issues.keep_if do |issue|
      issue[:labels].map(&:name).include? "Sprint 10/21"
    end.dup
  end

  def last_sprint_issues
    @all_issues.keep_if do |issue|
      issue[:labels].map(&:name).include? "Sprint 10/7"
    end.dup
  end

  private 

  def in_progress_issues
    @all_issues.keep_if do |issue|
      issue[:labels].map(&:name).include? "in progress"
    end.dup
  end




  def assignees_from_issues(issues)
    assignees = []
    issues.each do |issue|
      assignees << issue[:assignee] unless issue[:assignee].nil?
    end
    assignees.uniq!(&:login)
    
    return assignees
  end
end