class RemoveIsDefaultFromGlobalIssueTemplates < ActiveRecord::Migration
  def self.up
    remove_column :global_issue_templates, :is_default
  end

  def self.down
  end
end
