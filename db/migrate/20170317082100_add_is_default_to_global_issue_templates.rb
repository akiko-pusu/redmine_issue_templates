class AddIsDefaultToGlobalIssueTemplates < ActiveRecord::Migration
  def self.up
    add_column :global_issue_templates, :is_default, :boolean, default: false, null: false
  end

  def self.down
    remove_column :global_issue_templates, :is_default
  end
end
