class GlobalIssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Concerns::IssueTemplate::Common
  validates_uniqueness_of :title, scope: :tracker_id
  has_and_belongs_to_many :projects

  safe_attributes 'title',
                  'description',
                  'tracker_id',
                  'note',
                  'enabled',
                  'is_default',
                  'issue_title',
                  'project_ids',
                  'position',
                  'author_id'

  attr_accessible :title, :tracker_id, :issue_title, :description, :note,
                  :is_default, :enabled, :author_id, :position, :project_ids

  # for intermediate table assosciations
  scope :search_by_project, lambda { |project_id|
    joins(:projects).where(projects: { id: project_id }) if project_id.present?
  }

  module Config
    JSON_OBJECT_NAME = 'global_issue_template'.freeze
  end
  Config.freeze

  #
  # In case set is_default and updated, others are also updated.
  #
  def check_default
    return unless is_default? && is_default_changed?
    self.class.search_by_tracker(tracker_id).update_all(is_default: false)
  end

  #
  # Class method
  #
  class << self
    def get_templates_for_project_tracker(project_id, tracker_id = nil)
      GlobalIssueTemplate.search_by_tracker(tracker_id)
                         .search_by_project(project_id)
                         .enabled
                         .sorted
    end
  end
end
