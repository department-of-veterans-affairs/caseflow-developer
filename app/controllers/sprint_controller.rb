class SprintController < ApplicationController
	before_action :authenticate_user!

	def standup
		@in_progress_by_assignee = Github.new(params[:team]).in_progress_by_assignee
	end

	def closed_issues
		github = Github.new
		@current_sprint_issues = github.closed_issues
	end
end
