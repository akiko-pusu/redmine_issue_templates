class CreateProjectsGlobalIssueTemplates < ActiveRecord::Migration
  def self.up
     create_table :projects_global_issue_templates, :id => false do |t|
       t.integer :project_id
       t.integer :global_issue_template_id
     end
  end
  def self.down
     drop_table :projects_global_issue_templates
  end
end