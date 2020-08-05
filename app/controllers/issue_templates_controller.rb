# frozen_string_literal: true

# noinspection ALL
class IssueTemplatesController < ApplicationController
  layout 'base'
  helper :issues
  include Concerns::IssueTemplatesCommon
  include Concerns::ProjectTemplatesCommon
  menu_item :issues
  before_action :find_tracker, :find_templates, only: %i[set_pulldown list_templates]

  def index
    project_id = @project.id
    project_templates = IssueTemplate.search_by_project(project_id)

    # pick up used tracker ids
    tracker_ids = @project.trackers.pluck(:id)

    @template_map = {}
    tracker_ids.each do |tracker_id|
      templates = project_templates.search_by_tracker(tracker_id).sorted
      @template_map[Tracker.find(tracker_id)] = templates if templates.any?
    end

    setting = IssueTemplateSetting.find_or_create(project_id)
    @inherit_templates = setting.get_inherit_templates

    @global_issue_templates = global_templates(tracker_ids)

    respond_to do |format|
      format.html do
        render layout: !request.xhr?,
               locals: { apply_all_projects: apply_all_projects?, tracker_ids: tracker_ids }
      end
      format.api do
        render formats: :json, locals: { project_templates: project_templates }
      end
    end
  end

  def new
    if params[:copy_from].present?
      @issue_template = IssueTemplate.find(params[:copy_from]).dup
      @issue_template.title = @issue_template.copy_title
    else
      # create empty instance
      @issue_template ||= IssueTemplate.new(author: @user, project: @project)
    end
    render render_form_params
  end

  def create
    @issue_template = IssueTemplate.new
    @issue_template.author = User.current
    @issue_template.project = @project

    begin
      @issue_template.safe_attributes = valid_params
    rescue ActiveRecord::SerializationTypeMismatch, Concerns::IssueTemplatesCommon::InvalidTemplateFormatError
      flash[:error] = I18n.t(:builtin_fields_should_be_valid_json, default: 'Please enter a valid JSON fotmat string.')
      render render_form_params.merge(action: :new)
      return
    end

    # TODO: Should return validation error in case mandatory fields are blank.
    save_and_flash(:notice_successful_create, :new) && return
  end

  def update
    begin
      @issue_template.safe_attributes = valid_params
    rescue ActiveRecord::SerializationTypeMismatch, Concerns::IssueTemplatesCommon::InvalidTemplateFormatError
      flash[:error] = I18n.t(:builtin_fields_should_be_valid_json, default: 'Please enter a valid JSON fotmat string.')
      render render_form_params.merge(action: :show)
      return
    end
    save_and_flash(:notice_successful_update, :show)
  end

  # load template description
  def load
    issue_template_id = params[:template_id]
    template_type = params[:template_type]
    issue_template = if template_type.present? && template_type == 'global'
                       GlobalIssueTemplate.find(issue_template_id)
                     else
                       IssueTemplate.find(issue_template_id)
                     end
    rendered_json = builtin_fields_enabled? ? issue_template.template_json : issue_template.template_json(except: 'builtin_fields_json')

    render plain: rendered_json
  end

  # update pulldown
  def set_pulldown
    @group = []
    @default_template = nil

    add_templates_to_group(@issue_templates)
    add_templates_to_group(@inherit_templates, class: 'inherited')
    add_templates_to_group(@global_templates, class: 'global')

    if loadable_trigger?
      @group[@default_template].selected = 'selected'
    end

    render action: '_template_pulldown', layout: false,
           locals: { is_triggered_by: request.parameters[:is_triggered_by], grouped_options: @group,
                     should_replaced: setting.should_replaced, default_template: @default_template }
  end

  #
  # List templates associated with tracker and project.
  # TODO: refactor here. Duplicate with set_pulldown....
  #
  def list_templates
    (default_global, default_inherit, default_project) = default_templates

    default_template = default_inherit.presence || default_global
    default_template = default_project.presence || default_template

    respond_to do |format|
      format.html do
        render action: '_list_templates',
               layout: false,
               locals: { default_template: default_template,
                         issue_templates: @issue_templates,
                         inherit_templates: @inherit_templates,
                         global_issue_templates: @global_templates }
      end
      format.api do
        render action: '_list_templates',
               locals: { default_template: default_template,
                         issue_templates: @issue_templates,
                         inherit_templates: @inherit_templates,
                         global_issue_templates: @global_templates }
      end
    end
  end

  def menu_items
    { issue_templates: { default: :issue_templates, actions: {} } }
  end

  # preview
  def preview
    issue_template = params[:issue_template]
    @text = (issue_template ? issue_template[:description] : nil)
    render partial: 'common/preview'
  end

  private

  def orphaned
    IssueTemplate.orphaned(@project.id)
  end

  def find_object
    @issue_template = IssueTemplate.find(params[:id])
    @project = @issue_template.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_templates
    @issue_templates = issue_templates
    @inherit_templates = inherit_templates
    @global_templates = global_templates(@tracker.id)
  end

  def template
    @issue_template
  end

  def setting
    IssueTemplateSetting.find_or_create(@project.id)
  end

  def global_templates(tracker_id)
    return [] if apply_all_projects? && templates_exist?

    project_id = apply_all_projects? ? nil : @project.id
    GlobalIssueTemplate.get_templates_for_project_tracker(project_id, tracker_id)
  end

  def default_templates
    [@global_templates, @inherit_templates, @issue_templates].map do |templates|
      templates.try(:is_default).try(:first)
    end
  end

  def default_template_index
    @default_template.blank? ? @group.length - 1 : @default_template
  end

  def add_templates_to_group(templates, option = {})
    templates.each do |template|
      @group << template.template_struct(option)
      next unless template.is_default == true

      @default_template = default_template_index
    end
  end

  def issue_templates
    if params[:issue_project_id]
      @project = Project.find(params[:issue_project_id])
    end
    IssueTemplate.get_templates_for_project_tracker(@project.id, @tracker.id)
  end

  def inherit_templates
    setting.get_inherit_templates(@tracker)
  end

  def template_params
    params.require(:issue_template).permit(:tracker_id, :title, :note, :issue_title, :description, :is_default,
                                           :enabled, :author_id, :position, :enabled_sharing,
                                           :related_link, :link_title, :builtin_fields)
  end

  def templates_exist?
    @inherit_templates.present? || @issue_templates.present?
  end

  def render_form_params
    child_project_used_count = template&.used_projects&.count
    custom_fields = core_fields_map_by_tracker_id(tracker_id: template&.tracker_id, project_id: @project.id)
                    .merge(custom_fields_map_by_tracker_id(template&.tracker_id)).to_json

    { layout: !request.xhr?,
      locals: { issue_template: template, project: @project, child_project_used_count: child_project_used_count,
                custom_fields: custom_fields.to_s, builtin_fields_enable: builtin_fields_enabled? } }
  end

  def loadable_trigger?
    is_triggered_by = request.parameters[:is_triggered_by]
    is_update_issue = request.parameters[:is_update_issue]

    return false if is_triggered_by.present? && is_triggered_by != 'is_update_issue'
    return @default_template.present? && (is_update_issue.blank? || is_update_issue != 'true')
  end
end
