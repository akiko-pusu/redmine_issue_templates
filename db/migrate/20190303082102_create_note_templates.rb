class CreateNoteTemplates < ActiveRecord::Migration[5.1]
  def up
    create_table :note_templates do |t|
      t.string :name
      t.string :description
      t.string :memo
      t.integer :project_id
      t.integer :tracker_id
      t.integer :author_id
      t.boolean :enabled
      t.integer :position
      t.timestamps
    end
    add_index :note_templates, :author_id
    add_index :note_templates, :project_id
    add_index :note_templates, :tracker_id
    add_index :note_templates, :enabled
  end

  def down
    remove_index :note_templates, :author_id
    remove_index :note_templates, :project_id
    remove_index :note_templates, :tracker_id
    remove_index :note_templates, :enabled
    drop_table :note_templates
  end
end
