class SprintController < ApplicationController
	before_action :authenticate_user!

	def standup
		github = Github.new(params[:team])
		@in_progress_by_assignee = github.in_progress_by_assignee
		@in_validation_issues = github.in_validation_issues if params[:team] == 'CASEFLOW'
	end

	def closed_issues
		# github = Github.new
		# @current_sprint_issues = github.closed_issues
	end
end
