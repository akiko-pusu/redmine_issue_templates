class AddChecklistJsonToIssueTemplates < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issue_templates, :checklist_json, :text
  end

  def self.down
    remove_column :issue_templates, :checklist_json
  end
end
