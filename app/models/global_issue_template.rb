class GlobalIssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :tracker
  validates :title, presence: true
  validates :tracker, presence: true
  validates_uniqueness_of :title, scope: :tracker_id
  acts_as_list scope: :tracker

  has_and_belongs_to_many :projects

  # author and project should be stable.
  safe_attributes 'title',
                  'description',
                  'tracker_id',
                  'note',
                  'enabled',
                  'issue_title',
                  'project_ids',
                  'position',
                  'author_id'
  attr_accessible :title, :tracker_id, :issue_title, :description, :note,
                  :enabled, :project_ids, :position, :author_id

  scope :enabled, -> { where(enabled: true) }
  scope :order_by_position, -> { order(:position) }
  scope :search_by_tracker, lambda { |tracker_id|
    where(tracker_id: tracker_id) if tracker_id.present?
  }
  scope :search_by_project, lambda { |project_id|
    joins(:projects).where(projects: { id: project_id })
  }

  def enabled?
    enabled
  end

  def <=>(global_issue_template)
    position <=> global_issue_template.position
  end

  #
  # Class method
  #
  class << self
    def get_templates_for_project_tracker(project_id, tracker_id = nil)
      GlobalIssueTemplate.joins(:projects)
                         .search_by_tracker(tracker_id)
                         .search_by_project(project_id)
                         .enabled
                         .order_by_position
    end
  end
end
