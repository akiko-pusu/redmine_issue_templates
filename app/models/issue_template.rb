# frozen_string_literal: true

class IssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Concerns::IssueTemplate::Common
  belongs_to :project
  validates :project_id, presence: true
  validates :title, uniqueness: { scope: :project_id }
  acts_as_positioned scope: %i[project_id tracker_id]

  # author and project should be stable.
  safe_attributes 'title',
                  'description',
                  'tracker_id',
                  'note',
                  'enabled',
                  'issue_title',
                  'is_default',
                  'enabled_sharing',
                  'visible_children',
                  'position',
                  'related_link',
                  'link_title',
                  'builtin_fields_json'

  scope :enabled_sharing, -> { where(enabled_sharing: true) }
  scope :search_by_project, lambda { |prolect_id|
    where(project_id: prolect_id)
  }

  module Config
    JSON_OBJECT_NAME = 'issue_template'
  end
  Config.freeze

  #
  # In case set is_default and updated, others are also updated.
  #
  def check_default
    return unless is_default? && is_default_changed?

    self.class.search_by_project(project_id).search_by_tracker(tracker_id).update_all(is_default: false)
  end

  # return projects that use this template
  def used_projects
    return [] unless enabled_sharing

    projects = project.descendants
                      .joins(:trackers, :enabled_modules).merge(Tracker.where(id: tracker_id)).merge(EnabledModule.where(name: 'issue_templates'))
    IssueTemplateSetting.where(project_id: projects).inherit_templates.select(:project_id)
  end

  #
  # Class method
  #
  class << self
    def get_inherit_templates(project_ids, tracker_id)
      # keep ordering of project tree
      IssueTemplate.search_by_project(project_ids)
                   .search_by_tracker(tracker_id)
                   .enabled
                   .enabled_sharing
                   .sorted
    end

    def get_templates_for_project_tracker(project_id, tracker_id = nil)
      IssueTemplate.search_by_project(project_id)
                   .search_by_tracker(tracker_id)
                   .enabled
                   .sorted
    end
  end
end
