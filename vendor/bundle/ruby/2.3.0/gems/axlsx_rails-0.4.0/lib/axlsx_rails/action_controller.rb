require 'action_controller'
unless defined? Mime::XLSX
	Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
end

ActionController::Renderers.add :xlsx do |filename, options|
  #
  # You can always specify a template:
  #
  #  def called_action
  #    render xlsx: 'filename', template: 'controller/diff_action'
  #  end
  # 
  # And the normal use case works:
  #
  #  def called_action
  #    render 'diff_action'
  #    # or
  #    render 'controller/diff_action'
  #  end
  #
  if options[:template] == action_name
    options[:template] = filename.gsub(/^.*\//,'')
  end

  # disposition / filename
  disposition   = options.delete(:disposition) || 'attachment'
  if file_name = options.delete(:filename)
    file_name += ".xlsx" unless file_name =~ /\.xlsx$/
  else
    file_name = "#{filename.gsub(/^.*\//,'')}.xlsx"
  end

  # alternate settings
  options[:locals] ||= {}
  options[:locals][:xlsx_author] ||= options.delete(:xlsx_author)
  options[:locals][:xlsx_created_at] ||= options.delete(:xlsx_created_at)
  if options[:locals][:xlsx_use_shared_strings].nil?
    options[:locals][:xlsx_use_shared_strings] = options.delete(:xlsx_use_shared_strings)
  end

  send_data render_to_string(options), :filename => file_name, :type => Mime::XLSX, :disposition => disposition
end

# For respond_to default
begin
  ActionController::Responder
rescue
else
  class ActionController::Responder
    def to_xlsx
      if @default_response
        @default_response.call(options)
      else
        controller.render({:xlsx => controller.action_name}.merge(options))
      end
    end
  end
end