class IssueTemplateSetting < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :project

  validates_uniqueness_of :project_id
  validates_presence_of :project_id

  safe_attributes 'help_message', 'enabled', 'inherit_templates', 'should_replaced'
  attr_accessible :help_message, :enabled, :inherit_templates, :should_replaced

  def self.find_or_create(project_id)
    setting = IssueTemplateSetting.where(project_id: project_id).first
    unless setting.present?
      setting = IssueTemplateSetting.new
      setting.project_id = project_id
      setting.save!
    end
    setting
  end

  def enable_help?
    return true if enabled == true && !help_message.blank?
    false
  end

  def enabled_inherit_templates?
    return true if inherit_templates
    false
  end
end
