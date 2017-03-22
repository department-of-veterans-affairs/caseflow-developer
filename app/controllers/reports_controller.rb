class ReportsController < ApplicationController
	 respond_to :xlsx, :html
  def weekly_report
    @github = Github.new
    @weekly_report = @github.get_all_support_issues
    respond_to do |format|
      format.html
      format.xlsx {render xlsx: "reports/report"}
     end
  end
end
