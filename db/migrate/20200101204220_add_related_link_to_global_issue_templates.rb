# frozen_string_literal: true

class AddRelatedLinkToGlobalIssueTemplates < ActiveRecord::Migration[5.2]
  def self.up
    add_column :global_issue_templates, :related_link, :text
  end

  def self.down
    remove_column :global_issue_templates, :related_link
  end
end
