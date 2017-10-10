module ApplicationHelper
  def log_timing(name)
    Rails.logger.debug "Starting action '#{name}'."
    start_time_ms = Time.now
    yield
    elapsed_time = Time.now - start_time_ms
    Rails.logger.debug "Action '#{name}' took #{elapsed_time}s."
  end
end
