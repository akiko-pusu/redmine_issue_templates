# frozen_string_literal: true

class GlobalNoteTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  include ActiveModel::Validations

  # author and project should be stable.
  safe_attributes 'name',
                  'description',
                  'enabled',
                  'memo',
                  'tracker_id',
                  'position',
                  'visibility',
                  'role_ids',
                  'project_ids'

  validates :role_ids, presence: true, if: :roles?

  belongs_to :author, class_name: 'User', inverse_of: false, foreign_key: 'author_id'
  belongs_to :tracker

  has_many :global_note_template_projects, dependent: :nullify
  has_many :projects, through: :global_note_template_projects

  has_many :global_note_visible_roles, dependent: :nullify
  has_many :roles, through: :global_note_visible_roles

  validates :name, presence: true
  acts_as_positioned scope: %i[tracker_id]

  enum visibility: { roles: 1, open: 2 }

  scope :mine_condition, lambda { |user_id|
    where(author_id: user_id).mine if user_id.present?
  }

  scope :roles_condition, lambda { |role_ids|
    joins(:global_note_visible_roles).where(global_note_visible_roles: { role_id: role_ids })
  }

  scope :enabled, -> { where(enabled: true) }
  scope :sorted, -> { order(:position) }
  scope :search_by_tracker, lambda { |tracker_id|
    where(tracker_id: tracker_id) if tracker_id.present?
  }

  # for intermediate table assosciations
  scope :search_by_project, lambda { |project_id|
    joins(:projects).where(projects: { id: project_id }) if project_id.present?
  }

  before_save :check_visible_roles
  after_save :note_visible_roles!
  before_destroy :confirm_disabled

  def <=>(other)
    position <=> other.position
  end

  def template_json
    template = {}
    template['note_template'] = generate_json
    template.to_json(root: true)
  end

  def generate_json
    attributes
  end

  def note_visible_roles!
    return unless roles?

    if role_ids.blank?
      raise NoteTemplateError, l(:please_select_at_least_one_role,
                                 default: 'Please select at least one role.')
    end

    ActiveRecord::Base.transaction do
      GlobalNoteVisibleRole.where(global_note_template_id: id).delete_all if global_note_visible_roles.present?
      role_ids.each do |role_id|
        GlobalNoteVisibleRole.create!(global_note_template_id: id, role_id: role_id)
      end
    end
  end

  def loadable?(user_id:, project_id:)
    return true if open?

    project = Project.find(project_id)
    user_project_roles = User.find(user_id).roles_for_project(project).pluck(:id)
    match_roles = user_project_roles & roles.ids

    return true if roles? && match_roles.present?

    false
  end

  private

  def check_visible_roles
    return if roles? || global_note_visible_roles.empty?

    # Remove roles in case template visible scope is not "roles".
    # This remove action is included the same transaction scope.
    GlobalNoteVisibleRole.where(global_note_template_id: id).delete_all
  end

  def confirm_disabled
    return unless enabled?

    errors.add :base, 'enabled_template_cannot_destroy'
    throw :abort
  end

  #
  # Class method
  #
  class << self
    def visible_note_templates_condition(user_id:, project_id:, tracker_id:)
      user = User.find(user_id)
      project = Project.find(project_id)
      user_project_roles = user.roles_for_project(project).pluck(:id)

      base_condition = GlobalNoteTemplate.search_by_tracker(tracker_id)
      base_condition = base_condition.search_by_project(project_id) unless apply_all_projects?

      open_ids = base_condition.open.pluck(:id)
      role_ids = base_condition.roles_condition(user_project_roles).pluck(:id)

      # return uniq ids
      ids = open_ids | role_ids
      GlobalNoteTemplate.where(id: ids).includes(:global_note_visible_roles)
    end

    def get_templates_for_project_tracker(project_id, tracker_id = nil)
      GlobalNoteTemplate.search_by_tracker(tracker_id)
                        .search_by_project(project_id)
                        .enabled
                        .sorted
    end

    def plugin_setting
      Setting.plugin_redmine_issue_templates
    end

    def apply_all_projects?
      plugin_setting['apply_global_template_to_all_projects'].to_s == 'true'
    end
  end
end
