# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Developer: #{n}" }
    builtin { 0 }
    issues_visibility { 'default' }
    users_visibility { 'all' }
    position { 1 }
    permissions { %i[
      edit_project
      manage_members
      manage_versions
      manage_categories
      view_issues
      add_issues
      edit_issues
      copy_issues
      manage_issue_relations
      manage_subtasks
      add_issue_notes
      delete_issues
      view_issue_watchers
      save_queries
      view_gantt
      view_calendar
      log_time
      view_time_entries
      edit_own_time_entries
      manage_news
      comment_news
      view_documents
      add_documents
      edit_documents
      delete_documents
      view_wiki_pages
      view_wiki_edits
      edit_wiki_pages
      protect_wiki_pages
      delete_wiki_pages
      add_messages
      edit_own_messages
      delete_own_messages
      manage_boards
      view_files
      manage_files
      browse_repository
      view_changesets
    ] }

    trait :manager_role do
      name { 'Manager' }
      issues_visibility { 'all' }
      users_visibility { 'all' }
      permissions { %i[
        add_project
        edit_project
        close_project
        select_project_modules
        manage_members
        manage_versions
        manage_categories
        view_issues
        add_issues
        edit_issues
        manage_issue_relations
        manage_subtasks
        add_issue_notes
        delete_issues
        view_issue_watchers
        set_issues_private
        set_notes_private
        view_private_notes
        delete_issue_watchers
        manage_public_queries
        save_queries
        view_gantt
        view_calendar
        log_time
        view_time_entries
        edit_own_time_entries
        delete_time_entries
        manage_news
        comment_news
        view_documents
        add_documents
        edit_documents
        delete_documents
        view_wiki_pages
        view_wiki_edits
        edit_wiki_pages
        delete_wiki_pages_attachments
        protect_wiki_pages
        delete_wiki_pages
        rename_wiki_pages
        add_messages
        edit_own_messages
        delete_own_messages
        manage_boards
        view_files
        manage_files
        browse_repository
        manage_repository
        view_changesets
        manage_related_issues
        manage_project_activities
      ] }
    end
  end
end
