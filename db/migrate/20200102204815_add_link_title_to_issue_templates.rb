# frozen_string_literal: true

class AddLinkTitleToIssueTemplates < ActiveRecord::Migration[5.2]
  def self.up
    add_column :issue_templates, :link_title, :text
  end

  def self.down
    remove_column :issue_templates, :link_title
  end
end
