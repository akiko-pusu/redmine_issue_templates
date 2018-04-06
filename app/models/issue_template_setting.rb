class IssueTemplateSetting < ActiveRecord::Base
  include Redmine::SafeAttributes
  belongs_to :project

  validates_uniqueness_of :project_id
  validates_presence_of :project_id

  safe_attributes 'help_message', 'enabled', 'inherit_templates', 'should_replaced'
  attr_accessible :help_message, :enabled, :inherit_templates, :should_replaced

  scope :inherit_templates, -> { where(inherit_templates: true) }

  def self.find_or_create(project_id)
    setting = IssueTemplateSetting.where(project_id: project_id).first
    unless setting.present?
      setting = IssueTemplateSetting.new
      setting.project_id = project_id
      setting.save!
    end
    setting
  end

  #
  # Class method
  #
  class << self
    def apply_template_to_child_projects(project_id)
      setting = find_setting(project_id)
      setting.apply_template_to_child_projects
    end

    def unapply_template_from_child_projects(project_id)
      setting = find_setting(project_id)
      setting.unapply_template_from_child_projects
    end

    private

    def find_setting(project_id)
      raise ArgumentError, 'Please specify valid project_id.' if project_id.blank?
      setting = IssueTemplateSetting.where(project_id: project_id).first
      raise ActiveRecord::RecordNotFound if setting.blank?
      setting
    end
  end

  def enable_help?
    enabled == true && !help_message.blank?
  end

  def enabled_inherit_templates?
    inherit_templates
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
