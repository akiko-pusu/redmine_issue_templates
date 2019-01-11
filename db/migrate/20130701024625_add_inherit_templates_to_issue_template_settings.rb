class AddInheritTemplatesToIssueTemplateSettings < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issue_template_settings, :inherit_templates, :boolean, default: false, null: false
  end

  def self.down
    remove_column :issue_template_settings, :inherit_templates
  end
end
