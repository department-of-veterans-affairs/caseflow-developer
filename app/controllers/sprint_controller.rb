class SprintController < ApplicationController
	before_action :authenticate_user!

	def index
		# client = Octokit::Client.new(:access_token => "5ff4a26913fa32655c941fb4bc7c652cd9e3fce7")
		Octokit.auto_paginate = true
		@repos = [
			{ name: "department-of-veterans-affairs/appeals-pm"},
			{	name: "department-of-veterans-affairs/caseflow-certification"},
			{	name: "department-of-veterans-affairs/caseflow-commons"},
			{	name: "department-of-veterans-affairs/caseflow-dashboard"},
			{	name: "department-of-veterans-affairs/appeals-deployment"},
			{	name: "department-of-veterans-affairs/caseflow-efolder" }
		]

		current_issues = []
		@repos.each do |repo|
			repo_issues = Octokit.list_issues(repo[:name])
			

			# This is overkill now that we only need 'in progress' and not &&
			repo_issues.keep_if do |issue|
				in_progress_label, result = false
				issue[:labels].each do |label|
					in_progress_label = true if label[:name] == "in progress" 
				end
				result = true if in_progress_label
				result 
			end

			current_issues << repo_issues
			repo[:count] = repo_issues.count
		end
		current_issues.flatten!

		@assignees = []

		current_issues.each do |issue|
			@assignees << issue[:assignee] unless issue[:assignee].nil?
		end
		@assignees.uniq! { |assignee| assignee[:login] }
		
		@assignees.each do |assignee|
			assignee[:issues] = []
		end
		@assignees << { login: "Not Assigned", issues: [] }

		current_issues.each do |issue|
			unless issue[:assignee].nil?
				@assignees.each do |assignee|
					if assignee[:login] == issue[:assignee][:login]
						assignee[:issues] << issue
					end
				end
			else
				@assignees.each do |assignee|
					if assignee[:login] == "Not Assigned"
						assignee[:issues] << issue
					end
				end
			end
		end
	end
end
