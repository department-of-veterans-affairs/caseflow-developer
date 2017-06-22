require 'rubygems'
require 'action_view'
include ActionView::Helpers::DateHelper

class CI
  def initialize
    @most_recent_build_count = 20
    @upper_limit_of_builds_to_check_for_failure = 100
    begin
      @caseflow = Travis::Repository.find('department-of-veterans-affairs/caseflow')
      
      # Cache the success rate while we are in the rescue block so all errors are caught.
      success_rate
      most_recent_failed_build_relative_time
    rescue => e
      puts "Travis health check error", e
      @init_failed = true
    end
  end

  attr_reader :init_failed, :most_recent_build_count, :upper_limit_of_builds_to_check_for_failure

  def get_master_builds(limit)
    @caseflow.each_build
        .select { |build| puts 'load build', build.id; build.branch_info === 'master'}
        .first(limit)
  end

  def most_recent_failed_build_relative_time
    unless @most_recent_failed_build_relative_time
      # TODO ensure that this lazily stops after the first unsuccessful build is found.
      most_recent_failed_build = 
        get_master_builds(@upper_limit_of_builds_to_check_for_failure).detect {|build| build.unsuccessful?}

      if most_recent_failed_build
        @most_recent_failed_build_relative_time = 
          distance_of_time_in_words(Time.now, most_recent_failed_build.finished_at)
      else
        @most_recent_failed_build_relative_time = nil
      end

    end
    @most_recent_failed_build_relative_time
  end

  def success_rate
    unless @success_rate
      master_builds = get_master_builds(@most_recent_build_count)
      @success_rate ||= master_builds.select {|build| build.passed?}.count / master_builds.size.to_f
    end

    @success_rate
  end

  def success_category
    if @init_failed
      'init-failed'
    elsif success_rate >= 0.95
      'safe'
    elsif success_rate >= 0.7
      'flakey'
    else
      'dangerous'
    end
  end
end
