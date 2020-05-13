# frozen_string_literal: true

class CreateGlobalNoteTemplates < ActiveRecord::Migration[5.1]
  def up
    create_table :global_note_templates do |t|
      t.string :name
      t.text :description
      t.string :memo
      t.integer :tracker_id
      t.integer :author_id
      t.boolean :enabled
      t.integer :position
      t.integer :visibility, default: 2
      t.timestamps
    end
    add_index :global_note_templates, :author_id
    add_index :global_note_templates, :tracker_id
    add_index :global_note_templates, :enabled
  end

  def down
    remove_index :global_note_templates, :author_id
    remove_index :global_note_templates, :tracker_id
    remove_index :global_note_templates, :enabled
    drop_table :global_note_templates
  end
end
