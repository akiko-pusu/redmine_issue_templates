class CreateGlobalIssueTemplatesProjects < ActiveRecord::Migration
  def self.up
    create_table :global_issue_templates_projects, id: false do |t|
      t.integer :project_id
      t.integer :global_issue_template_id
    end
  end

  def self.down
    drop_table :global_issue_templates_projects
  end
end
