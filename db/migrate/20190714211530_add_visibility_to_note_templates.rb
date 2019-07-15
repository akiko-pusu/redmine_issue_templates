# frozen_string_literal: true

class AddVisibilityToNoteTemplates < ActiveRecord::Migration[5.1]
  def self.up
    add_column :note_templates, :visibility, :integer, default: 2
  end

  def self.down
    remove_column :note_templates, :visibility
  end
end
