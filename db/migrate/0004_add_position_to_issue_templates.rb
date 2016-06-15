class AddPositionToIssueTemplates < ActiveRecord::Migration
  def self.up
    add_column :issue_templates, :position, :integer, default: 1

    IssueTemplate.reset_column_information

    issue_templates = IssueTemplate.all
    say_with_time('Update each template to set default position.') do
      issue_templates.each_with_index { |t, i| t.update_attribute(:position, i + 1) }
    end
  end

  def self.down
    remove_column :issue_templates, :position
  end
end
