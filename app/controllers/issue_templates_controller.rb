# noinspection ALL
class IssueTemplatesController < ApplicationController
  layout 'base'
  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  include Concerns::IssueTemplatesCommon
  menu_item :issues
  before_filter :find_object, only: [:show, :edit, :update, :destroy]
  before_filter :find_user, :find_project, :authorize, except: [:preview]
  before_filter :find_tracker, :find_templates, only: [:set_pulldown, :list_templates]
  accept_api_auth :index, :list_templates, :load

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
        render layout: !request.xhr?, locals: { apply_all_projects: apply_all_projects? }
      end
      format.api do
        render formats: :json, locals: { project_templates: project_templates }
      end
    end
  end

  def show
    render_form
  end

  def new
    if params[:id].present?
      @issue_template = IssueTemplate.find(params[:id]).dup
      @issue_template.title = @issue_template.copy_title
    else
      # create empty instance
      @issue_template ||= IssueTemplate.new(author: @user, project: @project)
    end

    if request.post?
      @issue_template.safe_attributes = template_params
      @issue_template.checklist_json = checklists.to_json

      save_and_flash(:notice_successful_create) && return
    end
    render_form
  end

  def update
    @issue_template.safe_attributes = template_params
    @issue_template.checklist_json = checklists.to_json
    save_and_flash(:notice_successful_update)
  end

  def edit
    # Change from request.post to request.patch for Rails4.
    return unless request.patch? || request.put?
    @issue_template.safe_attributes = template_params

    @issue_template.checklist_json = checklists.to_json

    save_and_flash(:notice_successful_update)
  end

  def destroy
    return unless request.post?
    unless @issue_template.destroy
      flash[:error] = l(:enabled_template_cannot_destroy)
      redirect_to action: :show, project_id: @project, id: @issue_template
      return
    end
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index', project_id: @project
  end

  # load template description
  def load
    issue_template_id = params[:issue_template]
    template_type = params[:template_type]
    issue_template = if !template_type.blank? && template_type == 'global'
                       GlobalIssueTemplate.find(issue_template_id)
                     else
                       IssueTemplate.find(issue_template_id)
                     end
    render text: issue_template.template_json
  end

  # update pulldown
  def set_pulldown
    @group = []
    @default_template = nil

    add_templates_to_group(@issue_templates)
    add_templates_to_group(@inherit_templates, class: 'inherited')
    add_templates_to_group(@global_templates, class: 'global')

    is_triggered_by_status = request.parameters[:is_triggered_by_status]
    @group[@default_template].selected = 'selected' if @default_template.present?

    render action: '_template_pulldown', layout: false,
           locals: { is_triggered_by_status: is_triggered_by_status, grouped_options: @group,
                     should_replaced: setting.should_replaced, default_template: @default_template }
  end

  #
  # List templates associated with tracker and project.
  # TODO: refactor here. Duplicate with set_pulldown....
  #
  def list_templates
    (default_global, default_inherit, default_project) = default_templates

    default_template = default_inherit.present? ? default_inherit : default_global
    default_template = default_project.present? ? default_project : default_template

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

  # preview
  def preview
    issue_template = params[:issue_template]
    @text = (issue_template ? issue_template[:description] : nil)
    render partial: 'common/preview'
  end

  def orphaned_templates
    orphaned = IssueTemplate.orphaned(@project.id)
    render partial: 'orphaned_templates', locals: { orphaned_templates: orphaned }
  end

  private

  def find_user
    @user = User.current
  end

  def find_tracker
    @tracker = Tracker.find(params[:issue_tracker_id])
  end

  def find_object
    @issue_template = IssueTemplate.find(params[:id])
    @project = @issue_template.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_templates
    @issue_templates = issue_templates
    @inherit_templates = inherit_templates
    @global_templates = global_templates(@tracker.id)
  end

  def save_and_flash(message)
    return unless @issue_template.save
    respond_to do |format|
      format.html do
        flash[:notice] = l(message)
        redirect_to action: 'show', id: @issue_template.id, project_id: @project
      end
      format.js { head 200 }
    end
  end

  def render_form
    render(layout: !request.xhr?,
           locals: { checklist_enabled: checklist_enabled?,
                     issue_template: @issue_template, project: @project })
  end

  def setting
    IssueTemplateSetting.find_or_create(@project.id)
  end

  def global_templates(tracker_id)
    if apply_all_projects? && (@inherit_templates.present? || @issue_templates.present?)
      return []
    end
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
    IssueTemplate.get_templates_for_project_tracker(@project.id, @tracker.id)
  end

  def inherit_templates
    setting.get_inherit_templates(@tracker)
  end

  def template_params
    params.require(:issue_template).permit(:tracker_id, :title, :note, :issue_title, :description, :is_default,
                                           :enabled, :author_id, :position, :enabled_sharing, checklists: [])
  end
end
