class IssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :tracker
  validates_presence_of :project, :title, :description, :tracker
  validates_uniqueness_of :title, :scope => :project_id
  acts_as_list :scope => :tracker
  
  # author and project should be stable.
  safe_attributes 'title', 'description', 'tracker_id', 'note', 'enabled', 'issue_title'

  def enabled?
    self.enabled == true
  end

  def <=>(issue_template)
    position <=> issue_template.position
  end
end
