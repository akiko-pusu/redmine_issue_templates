class CreateIssueTemplates < ActiveRecord::Migration
  def self.up
    create_table :issue_templates do |t|
      t.column :title, :string, null: false
      t.column :project_id, :integer
      t.column :tracker_id, :integer, null: false
      t.column :author_id, :integer, null: false
      t.column :note, :string
      t.column :description, :text
      t.column :enabled, :boolean
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
    end
    add_index :issue_templates, :author_id
    add_index :issue_templates, :project_id
    add_index :issue_templates, :tracker_id
  end

  def self.down
    remove_index :issue_templates, :author_id
    remove_index :issue_templates, :project_id
    remove_index :issue_templates, :tracker_id
    drop_table :issue_templates
  end
end
