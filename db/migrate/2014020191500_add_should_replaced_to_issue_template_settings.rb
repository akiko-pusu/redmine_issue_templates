class AddShouldReplacedToIssueTemplateSettings < ActiveRecord::Migration
  def self.up
    add_column :issue_template_settings, :should_replaced, :boolean, default: false
  end

  def self.down
    remove_column :issue_template_settings, :should_replaced
  end
end
