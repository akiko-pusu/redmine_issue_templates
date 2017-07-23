module IssueTemplatesHelper
  def project_tracker?(tracker, project)
    project.trackers.exists?(tracker)
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
end
