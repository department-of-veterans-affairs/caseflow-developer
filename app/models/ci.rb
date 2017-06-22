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

  def master_builds
    # This code is ugly af but Travis does not give us a nice, efficient way to query the builds.
    unless @master_builds
      @master_builds = []

      builds_loaded = 0
      have_seen_failure = false
      @caseflow.each_build do |build|
        builds_loaded += 1
        next unless build.branch_info == 'master'

        have_seen_failure = have_seen_failure || build.unsuccessful?

        @master_builds.push(build)
        break if @master_builds.size === @upper_limit_of_builds_to_check_for_failure || 
          (@master_builds.size > @most_recent_build_count && have_seen_failure)
      end

      puts "Loaded #{builds_loaded} builds"
    end

    @master_builds
  end

  def most_recent_failed_build_relative_time
    unless @most_recent_failed_build_relative_time
      most_recent_failed_build = 
        master_builds.detect {|build| build.unsuccessful?}

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
      recent_master_builds = master_builds.first(@most_recent_build_count)
      @success_rate ||= recent_master_builds.select {|build| build.passed?}.count / recent_master_builds.size.to_f
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
