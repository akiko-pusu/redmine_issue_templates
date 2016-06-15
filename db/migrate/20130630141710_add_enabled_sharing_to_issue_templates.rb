class AddEnabledSharingToIssueTemplates < ActiveRecord::Migration
  def self.up
    add_column :issue_templates, :enabled_sharing, :boolean, default: false
  end

  def self.down
    remove_column :issue_templates, :enabled_sharing
  end
end
