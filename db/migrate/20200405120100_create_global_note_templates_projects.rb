# frozen_string_literal: true

class CreateGlobalNoteTemplatesProjects < ActiveRecord::Migration[5.1]
  def self.up
    create_table :global_note_templates_projects, id: false do |t|
      t.integer :project_id
      t.integer :global_note_template_id
    end
    add_index :global_note_templates_projects,
      [:project_id, :global_note_template_id], unique: true,
      name: 'projects_global_note_templates'
  end

  def self.down
    remove_index :global_note_templates_projects, name: 'projects_global_note_templates'
    drop_table :global_note_templates_projects
  end
end
