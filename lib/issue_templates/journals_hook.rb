# frozen_string_literal: true

# To change this template, choose Tools | Templates
# and open the template in the editor.
module IssueTemplates
  class JournalsHook < Redmine::Hook::ViewListener
    def view_journals_notes_form_after_notes(context = {})
      journal = context[:journal]
      issue = journal.issue
      tracker_id = issue.try(:tracker_id)
      templates = target_templates(context, tracker_id)
      global_templates = global_note_templates(context, tracker_id)
      return if templates.empty? && global_templates.empty?

      context[:controller].send(
        :render_to_string,
        partial: 'issue_templates/note_form', locals: { type: 'template_edit_journal', templates: templates, issue: issue }
      )
    end

    # Add journal with edit issue
    def view_issues_edit_notes_bottom(context = {})
      issue = context[:issue]
      tracker_id = issue.try(:tracker_id)
      templates = target_templates(context, tracker_id)
      global_templates = global_note_templates(context, tracker_id)
      return if templates.empty? && global_templates.empty?

      context[:controller].send(
        :render_to_string,
        partial: 'issue_templates/note_form', locals: { type: 'template_issue_notes', templates: templates, issue: issue }
      )
    end

    def target_templates(context, tracker_id)
      (tracker_id, project_id) = tracker_project_ids(context, tracker_id)
      NoteTemplate.visible_note_templates_condition(
        user_id: User.current.id, project_id: project_id, tracker_id: tracker_id
      )
    end

    def global_note_templates(context, tracker_id)
      (tracker_id, project_id) = tracker_project_ids(context, tracker_id)
      GlobalNoteTemplate.visible_note_templates_condition(
        user_id: User.current.id, project_id: project_id, tracker_id: tracker_id
      )
    end

    def tracker_project_ids(context, tracker_id)
      project = context[:project]
      project_id = project.present? ? project.id : issue.try(:project_id)
      [tracker_id, project_id]
    end
  end
end
