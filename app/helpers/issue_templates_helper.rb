module IssueTemplatesHelper
  def is_project_tracker(tracker_id, project)
    if project.trackers.exists?(tracker_id)
      return true
    end
    false
  end

  def non_project_tracker_msg(flag)
    return '' if flag
    "<font class=\"non_project_tracker\">#{l(:unused_tracker_at_this_project)}</font>".html_safe
  end

  def template_target_trackers(project, issue_template)
    trackers = project.trackers
    unless issue_template.tracker_id.blank?
      trackers = trackers | [issue_template.tracker]
    end
    trackers = trackers.collect {|t| [t.name, t.id]}
    trackers
  end
end
