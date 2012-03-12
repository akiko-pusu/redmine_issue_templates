class IssueTemplate < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :tracker
  validates_presence_of :project, :title, :description, :tracker
  validates_uniqueness_of :title, :scope => :project_id
                   
  def enabled?
    self.enabled == true
  end
end
