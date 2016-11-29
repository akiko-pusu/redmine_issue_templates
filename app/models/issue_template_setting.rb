class IssueTemplateSetting < ActiveRecord::Base
  #
  # Class method
  #
  class << self
    def apply_template_to_child_projects(project_id:)
      setting = IssueTemplateSetting.find(project_id)
      setting.apply_template_to_child_projects
    end

    def unapply_template_from_child_projects(project_id:)
      setting = IssueTemplateSetting.find(project_id)
      setting.unapply_template_from_child_projects
    end
  end

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

  def child_projects
    project.descendants
  end

  def apply_template_to_child_projects
    update_inherit_template_of_child_projects(true)
  end

  def unapply_template_from_child_projects
    update_inherit_template_of_child_projects(false)
  end

  def get_inherit_templates(tracker = nil)
    return [] unless enabled_inherit_templates?

    project_ids = project.ancestors.collect(&:id)
    tracker = project.trackers.pluck(:tracker_id) if tracker.blank?

    # first: get inherit_templates
    IssueTemplate.get_inherit_templates(project_ids, tracker)
  end

  private

  def update_inherit_template_of_child_projects(value)
    IssueTemplateSetting.where(project_id: child_projects).update_all(inherit_templates: value)
  end
end
