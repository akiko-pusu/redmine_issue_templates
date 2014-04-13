class CreateGlobalIssueTemplates < ActiveRecord::Migration
  def change
    create_table :global_issue_templates do |t|
      t.string :title
      t.string :issue_title
      t.integer :tracker_id
      t.integer :author_id
      t.string :note
      t.text :description
      t.boolean :enabled
      t.integer :position
      t.boolean :is_default
      t.timestamp :created_on
      t.timestamp :updated_on
    end
    add_index :global_issue_templates, :author_id
    add_index :global_issue_templates, :tracker_id
  end

  def self.down
    remove_index :global_issue_templates, :author_id
    remove_index :global_issue_templates, :tracker_id
    drop_table :global_issue_templates
  end
end
