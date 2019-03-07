# To change this template, choose Tools | Templates
# and open the template in the editor.
module IssueTemplates
  class JournalsHook < Redmine::Hook::ViewListener
    def view_journals_notes_form_after_notes(context = {})
      journal = context[:journal]
      issue = journal.issue
      tracker_id = issue.try(:tracker_id)
      templates = target_templates(context, tracker_id)
      return if templates.empty?

      context[:controller].send(
        :render_to_string,
        partial: 'issue_templates/note_form', locals: { type: 'template_edit_journal', templates: templates, issue: issue }
      )
    end

    # Add journaal with edit issue
    def view_issues_edit_notes_bottom(context = {})
      issue = context[:issue]
      tracker_id = issue.try(:tracker_id)
      templates = target_templates(context, tracker_id)
      return if templates.empty?

      context[:controller].send(
        :render_to_string,
        partial: 'issue_templates/note_form', locals: { type: 'template_issue_notes', templates: templates, issue: issue }
      )
    end

    def target_templates(context, tracker_id)
      (tracker_id, project_id) = tracker_project_ids(context, tracker_id)
      NoteTemplate.search_by_tracker(tracker_id).search_by_project(project_id)
    end

    def tracker_project_ids(context, tracker_id)
      project = context[:project]
      project_id = project.present? ? project.id : issue.try(:project_id)
      [tracker_id, project_id]
    end
  end
end

