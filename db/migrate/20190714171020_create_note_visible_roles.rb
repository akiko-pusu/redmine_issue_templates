# frozen_string_literal: true

class CreateNoteVisibleRoles < ActiveRecord::Migration[5.1]
  def up
    create_table :note_visible_roles do |t|
      t.integer :note_template_id
      t.integer :role_id
      t.timestamps
    end
    add_index :note_visible_roles, :note_template_id
    add_index :note_visible_roles, :role_id
  end

  def down
    remove_index :note_visible_roles, :role_id
    remove_index :note_visible_roles, :note_template_id
    drop_table :note_visible_roles
  end
end
