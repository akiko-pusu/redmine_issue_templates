# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NoteTemplateTest < ActiveSupport::TestCase
  fixtures :projects, :users, :trackers, :roles

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

  def teardown; end

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

  def test_visibility_with_success
    NoteTemplate.delete_all
    NoteTemplate.create(name: 'Template1', position: 2, project_id: 1, tracker_id: 1,
                        visibility: 'roles', role_ids: [Role.first.id])
    a = NoteTemplate.first
    assert_equal a.visibility_before_type_cast, 1

    a.visibility = 'mine'
    a.save
    assert_equal a.visibility_before_type_cast, 0
  end

  def test_visibility_without_role_ids
    NoteTemplate.delete_all

    # When enable validation: Raise ActiveRecord::RecordInvalid
    e = assert_raises ActiveRecord::RecordInvalid do
      NoteTemplate.create!(name: 'Template1', position: 2, project_id: 1, tracker_id: 1,
                           visibility: 'roles')
    end

    # Check error message.
    assert_equal 'Validation failed: Role ids cannot be blank', e.message
  end

  def test_visibility_from_mine_to_roles
    NoteTemplate.delete_all
    NoteTemplate.create(name: 'Template1', position: 2, project_id: 1, tracker_id: 1,
                        visibility: 'mine')
    a = NoteTemplate.first
    a.visibility = 'roles'

    # When skip validation: Raise: NoteTemplate::NoteTemplateError: Please select at least one role.
    e = assert_raises NoteTemplate::NoteTemplateError do
      a.save(validate: false)
    end

    # Check error message.
    assert_equal 'Please select at least one role.', e.message
  end
end
