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
                  'position'
  attr_accessible :title, :tracker_id, :issue_title, :description, :note,
                  :enabled, :project_ids, :position, :author

  scope :enabled, lambda { where(enabled: true) }
  scope :order_by_position, lambda { order(:position) }
  scope :search_by_tracker, lambda { |tracker_id|
    where(tracker_id: tracker_id)
  }
  scope :search_by_project, lambda { |project_id|
    joins(:projects).where(projects: { id: project_id })
  }

  def enabled?
    self.enabled
  end

  def <=>(global_issue_template)
    position <=> global_issue_template.position
  end
end
