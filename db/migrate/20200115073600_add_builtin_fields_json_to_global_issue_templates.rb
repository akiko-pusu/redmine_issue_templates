class AddBuiltinFieldsJsonToGlobalIssueTemplates < ActiveRecord::Migration[5.2]
  def self.up
    add_column :global_issue_templates, :builtin_fields_json, :text
  end

  def self.down
    remove_column :global_issue_templates, :builtin_fields_json
  end
end
