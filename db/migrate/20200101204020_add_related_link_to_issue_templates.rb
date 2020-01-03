# frozen_string_literal: true

class AddRelatedLinkToIssueTemplates < ActiveRecord::Migration[5.2]
  def self.up
    add_column :issue_templates, :related_link, :text
  end

  def self.down
    remove_column :issue_templates, :related_link
  end
end
