module IssueTemplatesHelper
  def project_tracker?(tracker, project)
    project.trackers.exists?(tracker.id)
  end

  def non_project_tracker_msg(flag)
    return '' if flag
    "<font class=\"non_project_tracker\">#{l(:unused_tracker_at_this_project)}</font>".html_safe
  end

  def template_target_trackers(project, issue_template)
    trackers = project.trackers
    trackers |= [issue_template.tracker] unless issue_template.tracker.blank?
    trackers.collect { |obj| [obj.name, obj.id] }
  end

  def options_for_template_pulldown(options)
    options.map do |option|
      text = option.try(:name).to_s
      content_tag_string(:option, text, option, true)
    end.join("\n").html_safe
  end

  def respond_to_missing?
    true
  end

  #
  # TODO: This is a workaround to keep compatibility against Redmine3.1 and 3.2.
  # rubocop:disable Lint/ShadowingOuterLocalVariable
  def method_missing(name, *args)
    if Redmine::VERSION::MINOR < 3 && name == 'reorder_handle'
      class_eval do
        define_method 'reorder_handle' do |*args|
          (object, options) = args
          data = {
            reorder_url: options[:url] || url_for(object),
            reorder_param: options[:param] || object.class.name.underscore
          }
          content_tag('span', '',
                      class: 'sort-handle',
                      data: data,
                      title: l(:button_sort))
        end
      end
      super
    end
    send(name, *args)
  end
end
