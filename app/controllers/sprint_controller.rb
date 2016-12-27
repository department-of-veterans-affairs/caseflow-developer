class SprintController < ApplicationController
	before_action :authenticate_user!

	def standup
		@github = Github.new
		@in_progress_by_assignee = @github.issues_by_assignee(params[:team], "In Progress")
		@in_validation_issues = @github.get_issues(params[:team], "In Validation") if params[:team] == 'CASEFLOW'
	end
end
