require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NoteTemplateTest < ActiveSupport::TestCase
  fixtures :projects, :users, :trackers

  def setup
    tracker = Tracker.first
    params = {
      author: User.first, project: Project.first,
      tracker: tracker
    }.merge(
      name: "Note Template name for Tracker #{tracker.name}.",
      description: "Note Template description for Tracker #{tracker.name}.",
      memo: "Note Template memo for Tracker #{tracker.name}.",
      enabled: true
    )
    @template = NoteTemplate.create(params)
  end

  def test_truth
    assert_kind_of NoteTemplate, @template
  end

  def test_template_enabled
    enabled = @template.enabled?
    assert_equal true, enabled, @template.enabled?

    @template.enabled = false
    @template.save!
    enabled = @template.enabled?
    assert_equal false, enabled, @template.enabled?
  end

  def test_sort_by_position
    a = NoteTemplate.new(name: 'Template1', position: 2, project_id: 1, tracker_id: 1)
    b = NoteTemplate.new(name: 'Template2', position: 1, project_id: 1, tracker_id: 1)
    assert_equal [b, a], [a, b].sort
  end
end
