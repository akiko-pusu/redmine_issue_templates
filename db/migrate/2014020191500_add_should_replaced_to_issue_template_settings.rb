class AddShouldReplacedToIssueTemplateSettings < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issue_template_settings, :should_replaced, :boolean, default: false
  end

  def self.down
    remove_column :issue_template_settings, :should_replaced
  end
end
