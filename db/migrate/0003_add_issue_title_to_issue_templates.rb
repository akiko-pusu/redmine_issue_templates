class AddIssueTitleToIssueTemplates < ActiveRecord::Migration
  def self.up
    add_column :issue_templates, :issue_title, :string

    IssueTemplate.reset_column_information
    issue_templates = IssueTemplate.all
    issue_templates.each do |t|
      t.issue_title = t.title
      t.save
    end
  end

  def self.down
    remove_column :issue_templates, :issue_title
  end
end
