# frozen_string_literal: true

class CreateGlobalNoteVisibleRoles < ActiveRecord::Migration[5.1]
  def up
    create_table :global_note_visible_roles do |t|
      t.integer :global_note_template_id
      t.integer :role_id
      t.timestamps
    end
    add_index :global_note_visible_roles, :global_note_template_id
    add_index :global_note_visible_roles, :role_id
  end

  def down
    remove_index :global_note_visible_roles, :role_id
    remove_index :global_note_visible_roles, :global_note_template_id
    drop_table :global_note_visible_roles
  end
end
