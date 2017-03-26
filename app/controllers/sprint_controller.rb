class SprintController < ApplicationController
	before_action :authenticate_user!
  respond_to :xlsx, :html
	def standup
		@github = Github.new
		@in_progress_by_assignee = @github.issues_by_assignee(params[:team], "In Progress")

    @in_progress_by_assignee_optional = []
    required_logins = @github.team_members.map {|i| i[:login] }
    @in_progress_by_assignee.each do |assignee, issues|
      next if issues.first[:assignee][:login] == "Unassigned"
      unless required_logins.include?(issues.first[:assignee][:login])
        @in_progress_by_assignee_optional << [assignee, issues]
        @in_progress_by_assignee.delete(assignee)
      end
    end

		@in_validation_issues = @github.get_issues(params[:team], "open", "In Validation") if params[:team] == 'CASEFLOW'
    @product_support_issues = @github.get_product_support_issues if params[:team] == 'APPEALS_PM' #changes made

	end

  def issues_report
    @github = Github.new
    @issues_by_project = @github.get_issues('CASEFLOW', "closed").group_by {|issue|  issue[:html_url].split("/")[4]}
  end

  def weekly_report
    @github = Github.new
    @weekly_report = @github.get_all_support_issues
    respond_to do |format|
      format.html
      format.xlsx {render xlsx: "report"}
     end
  end

  def incident_report
    @github = Github.new
     @incident_report = @github.get_all_incident_issues
      respond_to do |format|
      format.html
      format.xlsx {render xlsx: "incident_report"}
     end
  end
end





