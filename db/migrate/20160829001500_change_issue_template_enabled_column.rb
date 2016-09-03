class ChangeIssueTemplateEnabledColumn < ActiveRecord::Migration
  def self.up
    change_column :issue_templates, :enabled, :boolean, default: false, null: false
  end

  def self.down
    change_column :issue_templates, :enabled, :boolean
  end
end
