# frozen_string_literal: true

class GlobalNoteTemplateProject < ActiveRecord::Base
  belongs_to :project
  belongs_to :global_note_template, optional: true
end
