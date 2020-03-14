class ChangeColumnNoteTemplateDescription < ActiveRecord::Migration[5.2]
  def self.up
    change_column :note_templates, :description, :text
  end

  def down
     change_column :note_templates, :description, :string
  end
end
