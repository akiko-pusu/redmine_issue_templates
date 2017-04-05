class ChangeGlobalIssueTemplateEnabledColumn < ActiveRecord::Migration
  def self.up
    change_column :global_issue_templates, :enabled, :boolean, default: false, null: false
  end

  def self.down
    change_column :global_issue_templates, :enabled, :boolean
  end
end
