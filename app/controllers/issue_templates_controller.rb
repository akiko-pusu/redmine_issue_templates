# noinspection ALL
class IssueTemplatesController < ApplicationController
  unloadable
  layout 'base'
  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  include Concerns::TemplateRenderAction
  menu_item :issues
  before_filter :find_object, only: [:show, :edit, :destroy]
  before_filter :find_user, :find_project, :authorize,
                except: [:preview, :move_order_higher, :move_order_lower, :move_order_to_top, :move_order_to_bottom, :move]
  before_filter :find_tracker, only: [:set_pulldown, :list_templates]
  accept_api_auth :index, :list_templates, :load

  def index
    project_id = @project.id
    project_templates = IssueTemplate.search_by_project(project_id)

    # pick up used tracker ids
    tracker_ids = project_templates.pluck(:tracker_id).uniq

    @template_map = {}
    tracker_ids.each do |tracker_id|
      templates = project_templates.search_by_tracker(tracker_id).order_by_position
      @template_map[Tracker.find(tracker_id)] = templates if templates.any?
    end

    setting = IssueTemplateSetting.find_or_create(project_id)
    enabled_inherit_template = setting.enabled_inherit_templates?
    @inherit_templates = []

    project_ids = enabled_inherit_template ? @project.ancestors.collect(&:id) : []
    used_tracker_ids = @project.trackers.pluck(:tracker_id)
    @inherit_templates = IssueTemplate.get_inherit_templates(project_ids, used_tracker_ids)

    @global_issue_templates = GlobalIssueTemplate.get_templates_for_project_tracker(project_id)

    respond_to do |format|
      format.html do
        render layout: !request.xhr?
      end
      format.json do
        render formats: :json, handlers: 'jbuilder',
               locals: { project_templates: project_templates }
      end
    end
  end

  def show
  end

  def new
    # create empty instance
    @issue_template ||= IssueTemplate.new(author: @user, project: @project)
    if request.post?
      @issue_template.safe_attributes = params[:issue_template]
      save_and_flash
    end
  end

  def edit
    # Change from request.post to request.patch for Rails4.
    if request.patch? || request.put?
      @issue_template.safe_attributes = params[:issue_template]
      save_and_flash
    end
  end

  def destroy
    if request.post?
      if @issue_template.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to action: 'index', project_id: @project
      end
    end
  end

  # load template description
  def load
    issue_template_id = params[:issue_template]
    template_type = params[:template_type]
    @issue_template = if !template_type.blank? && template_type == 'global'
                        GlobalIssueTemplate.find(issue_template_id)
                      else
                        IssueTemplate.find(issue_template_id)
                      end
    render text: @issue_template.to_json(root: true)
  end

  # update pulldown
  def set_pulldown
    grouped_options = []
    group = []
    default_template = nil
    project_id = @project.id
    tracker_id = @tracker.id

    # first: get inherit_templates
    setting = IssueTemplateSetting.find_or_create(project_id)
    inherit_templates = get_inherit_templates(setting)

    inherit_templates.each do |template|
      group.push([template.title, template.id, { class: 'inherited' }])
      next unless template.is_default == true
      default_template = template.id
    end

    issue_templates = IssueTemplate.get_templates_for_project_tracker(project_id, tracker_id)

    project_default_template = issue_templates.is_default.first
    default_template = project_default_template.present? ? project_default_template.id : default_template

    global_issue_templates = GlobalIssueTemplate.get_templates_for_project_tracker(project_id, tracker_id)

    unless issue_templates.empty?
      issue_templates.each { |x| group.push([x.title, x.id]) }
    end

    if global_issue_templates.any?
      global_issue_templates.each do |global_issue_template|
        group.push([global_issue_template.title, global_issue_template.id, { class: 'global' }])
      end
    end

    is_triggered_by_status = request.parameters[:is_triggered_by_status]
    grouped_options.push([@tracker.name, group]) if group.any?
    render action: '_template_pulldown', layout: false,
           locals: { is_triggered_by_status: is_triggered_by_status, grouped_options: grouped_options,
                     should_replaced: setting.should_replaced, default_template: default_template }
  end

  #
  # List templates associated with tracker and project.
  # TODO: refactor here. Duplicate with set_pulldown....
  #
  def list_templates
    project_id = @project.id
    tracker_id = @tracker.id

    # first: get inherit_templates
    setting = IssueTemplateSetting.find_or_create(project_id)
    inherit_templates = get_inherit_templates(setting)

    issue_templates = IssueTemplate.get_templates_for_project_tracker(project_id, tracker_id)

    project_default_template = issue_templates.is_default.first
    default_template = project_default_template.present? ? project_default_template.id : default_template

    global_issue_templates = GlobalIssueTemplate.get_templates_for_project_tracker(project_id, tracker_id)

    respond_to do |format|
      format.html do
        render action: '_list_templates',
               layout: false,
               locals: { default_template: default_template,
                         issue_templates: issue_templates,
                         inherit_templates: inherit_templates,
                         global_issue_templates: global_issue_templates }
      end
      format.json do
        render action: '_list_templates', formats: 'json', handlers: 'jbuilder',
               locals: { default_template: default_template,
                         issue_templates: issue_templates,
                         inherit_templates: inherit_templates,
                         global_issue_templates: global_issue_templates }
      end
    end
  end

  # preview
  def preview
    issue_template = params[:issue_template]
    @text = (issue_template ? issue_template[:description] : nil)
    render partial: 'common/preview'
  end

  # Reorder templates
  def move
    move_order(params[:to])
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

  def move_order(method)
    IssueTemplate.find(params[:id]).send "move_#{method}"
    render_for_move_with_format
  end

  def save_and_flash
    if @issue_template.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'show', id: @issue_template.id, project_id: @project
    end
  end

  def get_inherit_templates(setting)
    enabled_inherit_template = setting.enabled_inherit_templates?

    project_ids = enabled_inherit_template ? @project.ancestors.collect(&:id) : []

    # first: get inherit_templates
    IssueTemplate.get_inherit_templates(project_ids, @tracker.id)
  end
end
