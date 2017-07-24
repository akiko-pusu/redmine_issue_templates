class ChangeIssueTemplateEnabledColumn < ActiveRecord::Migration[4.2]
  def self.up
    change_column :issue_templates, :enabled, :boolean, default: false, null: false
  end

  def self.down
    change_column :issue_templates, :enabled, :boolean
  end
end
