require File.dirname(__FILE__) + '/../test_helper'

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
end
