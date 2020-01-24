# frozen_string_literal: true

class AddLinkTitleToGlobalIssueTemplates < ActiveRecord::Migration[5.2]
  def self.up
    add_column :global_issue_templates, :link_title, :text
  end

  def self.down
    remove_column :global_issue_templates, :link_title
  end
end
