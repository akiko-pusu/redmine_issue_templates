class CreateIssueTemplateSettings < ActiveRecord::Migration
  def self.up
    create_table :issue_template_settings do |t|
      t.column :project_id, :integer

      t.column :help_message, :text

      t.column :enabled, :boolean
    end
  end

  def self.down
    drop_table :issue_template_settings
  end
end
