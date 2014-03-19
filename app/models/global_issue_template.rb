class GlobalIssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :tracker
  before_save :check_default
  validates :title, :presence => true
  validates :tracker, :presence => true
  validates_uniqueness_of :title, :scope => :tracker_id
  acts_as_list :scope => :tracker

  has_and_belongs_to_many :projects

  # author and project should be stable.
  safe_attributes 'title',
                  'description',
                  'tracker_id',
                  'note',
                  'enabled',
                  'issue_title',
                  'is_default',
                  'project_ids'

  def enabled?
    self.enabled == true
  end

  def <=>(issue_template)
    position <=> global_issue_template.position
  end

  #
  # In case set is_default and updated, others are also updated.
  #
  def check_default
    if is_default? && is_default_changed?
      GlobalIssueTemplate.update_all({:is_default => false},
                               ['racker_id = ?', tracker_id])
    end
  end
end
