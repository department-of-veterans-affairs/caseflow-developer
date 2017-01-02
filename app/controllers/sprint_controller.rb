class SprintController < ApplicationController
	before_action :authenticate_user!

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

		@in_validation_issues = @github.get_issues(params[:team], "In Validation") if params[:team] == 'CASEFLOW'
	end
end
