require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IssueTemplateTest < ActiveSupport::TestCase
  fixtures :issue_templates, :projects, :users, :trackers

  def setup
    @issue_template = IssueTemplate.find(1)
  end

  def test_truth
    assert_kind_of IssueTemplate, @issue_template
  end

  def test_template_enabled
    enabled = @issue_template.enabled?
    assert_equal true, enabled, @issue_template.enabled?

    @issue_template.enabled = false
    @issue_template.save!
    enabled = @issue_template.enabled?
    assert_equal false, enabled, @issue_template.enabled?
  end

  def test_sort_by_position
    a = IssueTemplate.new(title: 'Template1', position: 2, project_id: 1, tracker_id: 1)
    b = IssueTemplate.new(title: 'Template2', position: 1, project_id: 1, tracker_id: 1)
    assert_equal [b, a], [a, b].sort
  end

  def test_is_default
    # Reset default data
    IssueTemplate.update_all(is_default: false)
    assert !@issue_template.is_default?

    @issue_template.is_default = true
    @issue_template.save!
    assert @issue_template.is_default?

    templates = IssueTemplate.search_by_project(1).search_by_tracker(1).not_default
    templates.each do |template|
      assert !template.is_default?
    end
  end
end
