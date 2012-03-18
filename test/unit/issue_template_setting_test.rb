require File.dirname(__FILE__) + '/../test_helper'

class IssueTemplateSettingTest < ActiveSupport::TestCase
  fixtures :issue_template_settings, :projects

  def setup
    @issue_template_setting = IssueTemplateSetting.find(1)
  end    

  def test_truth
   assert_kind_of IssueTemplateSetting, @issue_template_setting
  end
  
  def test_help_message_enabled
    assert_equal(true, @issue_template_setting.enabled)
    assert_equal(false, !@issue_template_setting.enabled)
  end

  def test_duplicate_project_setting
    templ = IssueTemplateSetting.find_or_create(3)
    templ.attributes = {:enabled => true, :help_message => 'Help!'}
    assert templ.save!, 'Failed to save.'

    # test which has the same proect id
    templ2 = IssueTemplateSetting.new
    templ2.attributes = {:project_id => 1, :enabled => true, :help_message => 'Help!'}
    assert !templ2.save, 'Dupricate project should be denied.'
  end
end
