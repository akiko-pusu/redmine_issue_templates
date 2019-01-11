class AddChecklistJsonToGlobalIssueTemplates < ActiveRecord::Migration[4.2]
  def self.up
    add_column :global_issue_templates, :checklist_json, :text
  end

  def self.down
    remove_column :global_issue_templates, :checklist_json
  end
end
