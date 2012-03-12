class IssueTemplateSetting < ActiveRecord::Base
  unloadable
  belongs_to :project
  
  validates_uniqueness_of :project_id
  validates_presence_of :project_id
	
  def self.find_or_create(project_id)	
    setting = IssueTemplateSetting.find(:first, :conditions => ['project_id = ?', project_id])
    unless setting
      setting = IssueTemplateSetting.new
      setting.project_id = project_id
      setting.save!      
    end
    return setting
  end
  
  def enable_help?
    if self.enabled == true && !self.help_message.blank?
      return true
    end
    return false
  end
end
