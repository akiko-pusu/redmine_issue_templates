class NoteTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes

  # author and project should be stable.
  safe_attributes 'title', 'description', 'issue_template_id', 'enabled'

  belongs_to :project
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :tracker

  validates :project_id, presence: true
  validates_uniqueness_of :title, scope: :project_id
  validates :title, presence: true
  validates :issue_template, presence: true

  scope :enabled, -> {where(enabled: true)}
  scope :search_by_tracker, lambda {|tracker_id|
    where(tracker_id: tracker_id) if tracker_id.present?
  }
  scope :search_by_project, lambda {|prolect_id|
    where(project_id: prolect_id)
  }
end
