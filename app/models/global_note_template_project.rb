# frozen_string_literal: true

class GlobalNoteTemplateProject < ActiveRecord::Base
  belongs_to :global_note_template
  belongs_to :project
end
