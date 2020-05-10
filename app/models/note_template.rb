# frozen_string_literal: true

class NoteTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes
  include ActiveModel::Validations

  class NoteTemplateError < StandardError; end

  # author and project should be stable.
  safe_attributes 'name', 'description', 'enabled', 'memo', 'tracker_id',
                  'project_id', 'position', 'visibility'

  attr_accessor :role_ids
  validates :role_ids, presence: true, if: :roles?

  belongs_to :project
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :tracker

  has_many :note_visible_roles, dependent: :nullify
  has_many :roles, through: :note_visible_roles

  validates :project_id, presence: true
  validates :name, uniqueness: { scope: :project_id }
  validates :name, presence: true
  acts_as_positioned scope: %i[project_id tracker_id]

  enum visibility: { mine: 0, roles: 1, open: 2 }

  scope :mine_condition, lambda { |user_id|
    where(author_id: user_id).mine if user_id.present?
  }
  scope :roles_condition, lambda { |role_ids|
    joins(:note_visible_roles).where(note_visible_roles: { role_id: role_ids })
  }

  scope :enabled, -> { where(enabled: true) }
  scope :sorted, -> { order(:position) }
  scope :search_by_tracker, lambda { |tracker_id|
    where(tracker_id: tracker_id) if tracker_id.present?
  }
  scope :search_by_project, lambda { |prolect_id|
    where(project_id: prolect_id) if prolect_id.present?
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
      NoteVisibleRole.where(note_template_id: id).delete_all if note_visible_roles.present?
      role_ids.each do |role_id|
        NoteVisibleRole.create!(note_template_id: id, role_id: role_id)
      end
    end
  end

  def loadable?(user_id:)
    return true if open?
    return true if mine? && user_id == author_id

    user_project_roles = User.find(user_id).roles_for_project(project).pluck(:id)
    match_roles = user_project_roles & roles.ids
    return true if roles? && !match_roles.empty?

    false
  end

  private

  def check_visible_roles
    return if roles? || note_visible_roles.empty?

    # Remove roles in case template visible scope is not "roles".
    # This remove action is included the same transaction scope.
    NoteVisibleRole.where(note_template_id: id).delete_all
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

      base_condition = NoteTemplate.search_by_project(project_id).search_by_tracker(tracker_id)

      open_ids = base_condition.open.pluck(:id)
      mine_ids = base_condition.mine_condition(user_id).pluck(:id)
      role_ids = base_condition.roles_condition(user_project_roles).pluck(:id)

      # return uniq ids
      ids = open_ids | mine_ids | role_ids
      NoteTemplate.where(id: ids).includes(:note_visible_roles)
    end
  end
end
