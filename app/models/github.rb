class Assignee
end

class Repo

	def issues
		client = Octokit::Client.new(:access_token => "5ff4a26913fa32655c941fb4bc7c652cd9e3fce7")
		client.auto_paginate = true
		current_issues = client.list_issues("department-of-veterans-affairs/appeals-pm")
		
		issues = current_issues.keep_if do |issue|
			issue[:labels].each do |label|
				return true if label[:name] == "Sprint 10/7"
			end
		end

		return issues
	end

end

class Issue
end