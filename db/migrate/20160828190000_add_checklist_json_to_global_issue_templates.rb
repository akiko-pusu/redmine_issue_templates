class AddChecklistJsonToGlobalIssueTemplates < ActiveRecord::Migration
  def self.up
    add_column :global_issue_templates, :checklist_json, :text
  end

  def self.down
    remove_column :global_issue_templates, :checklist_json
  end
end
