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
    @issue_template.enabled = true
    @issue_template.save!
    assert_equal true, @issue_template.enabled?, @issue_template.enabled?
    
    @issue_template.enabled = false
    @issue_template.save!
    assert_equal false, @issue_template.enabled?, @issue_template.enabled?
  end  
end
