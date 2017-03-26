module IssueTemplatesHelper
  def project_tracker?(tracker_id, project)
    return true if project.trackers.exists?(tracker_id)
    false
  end

  def non_project_tracker_msg(flag)
    return '' if flag
    "<font class=\"non_project_tracker\">#{l(:unused_tracker_at_this_project)}</font>".html_safe
  end

  def template_target_trackers(project, issue_template)
    trackers = project.trackers
    trackers |= [issue_template.tracker] unless issue_template.tracker_id.blank?
    trackers = trackers.collect { |obj| [obj.name, obj.id] }
    trackers
  end

  def options_for_template_pulldown(options)
    options.map do |option|
      html_attributes = {}
      html_attributes[:selected] = option[:selected]
      html_attributes[:value] = option[:value]
      html_attributes[:class] = option[:class] if option[:class].present?
      text = option[:name]
      content_tag_string(:option, text, html_attributes)
    end.join("\n").html_safe
  end
end
