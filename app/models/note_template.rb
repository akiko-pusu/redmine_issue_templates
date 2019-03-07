class NoteTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes

  # author and project should be stable.
  safe_attributes 'name', 'description', 'enabled', 'memo', 'tracker_id', 'project_id', 'position'

  belongs_to :project
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :tracker

  validates :project_id, presence: true
  validates_uniqueness_of :name, scope: :project_id
  validates :name, presence: true
  acts_as_positioned scope: %i[project_id tracker_id]

  scope :enabled, -> { where(enabled: true) }
  scope :sorted, -> { order(:position) }
  scope :search_by_tracker, lambda { |tracker_id|
    where(tracker_id: tracker_id) if tracker_id.present?
  }
  scope :search_by_project, lambda { |prolect_id|
    where(project_id: prolect_id) if prolect_id.present?
  }

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
end
