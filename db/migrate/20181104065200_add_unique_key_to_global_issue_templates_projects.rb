class AddUniqueKeyToGlobalIssueTemplatesProjects < ActiveRecord::Migration[4.2]
  def self.up
    add_index :global_issue_templates_projects,
              [:project_id, :global_issue_template_id], unique: true,
              name: 'projects_global_issue_templates'
  end

  def self.down
    remove_index :global_issue_templates_projects, name: 'projects_global_issue_templates'
  end
end
