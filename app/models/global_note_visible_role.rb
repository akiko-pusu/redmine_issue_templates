# frozen_string_literal: true

class GlobalNoteVisibleRole < ActiveRecord::Base
  include Redmine::SafeAttributes

  safe_attributes 'global_note_template_id', 'role_id'
  belongs_to :role
  belongs_to :global_note_template, optional: true

  validates :role_id, presence: true
  validates :global_note_template_id, presence: true

  scope :search_by_note_template, lambda { |note_template_id|
    where(global_note_template_id: note_template_id)
  }
end
