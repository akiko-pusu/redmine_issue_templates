class IssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Concerns::IssueTemplate::Common
  unloadable
  belongs_to :project
  validates :project_id, presence: true
  validates_uniqueness_of :title, scope: :project_id

  # author and project should be stable.
  safe_attributes 'title', 'description', 'tracker_id', 'note', 'enabled', 'issue_title', 'is_default',
                  'enabled_sharing', 'visible_children', 'position'
  attr_accessible :title, :tracker_id, :issue_title, :description, :note,
                  :is_default, :enabled, :enabled_sharing, :author, :project, :position

  scope :enabled_sharing, -> { where(enabled_sharing: true) }
  scope :search_by_project, lambda { |prolect_id|
    where(project_id: prolect_id)
  }

  module Config
    JSON_OBJECT_NAME = 'issue_template'.freeze
  end
  Config.freeze

  #
  # In case set is_default and updated, others are also updated.
  #
  def check_default
    return unless is_default? && is_default_changed?
    self.class.search_by_project(project_id).search_by_tracker(tracker_id).update_all(is_default: false)
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
                   .order_by_position
    end

    def get_templates_for_project_tracker(project_id, tracker_id = nil)
      IssueTemplate.search_by_project(project_id)
                   .search_by_tracker(tracker_id)
                   .enabled
                   .order_by_position
    end
  end
end
