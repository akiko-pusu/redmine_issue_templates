# noinspection RubocopInspection
class GlobalIssueTemplatesController < ApplicationController
  unloadable
  layout 'base'
  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  include Concerns::TemplateRenderAction
  menu_item :issues
  before_filter :find_object, only: [:show, :edit, :destroy]
  before_filter :find_project, only: [:edit]
  before_filter :require_admin, only: [:index, :new, :show], excep: [:preview]

  #
  # Action for global template : Admin right is required.
  #
  def index
    trackers = Tracker.all
    template_map = {}
    trackers.each do |tracker|
      tracker_id = tracker.id
      templates = GlobalIssueTemplate.search_by_tracker(tracker_id).order_by_position
      template_map[Tracker.find(tracker_id)] = templates if templates.any?
    end
    render layout: !request.xhr?, locals: { template_map: template_map, trackers: trackers }
  end

  def new
    # create empty instance
    trackers = Tracker.all
    projects = Project.all
    @global_issue_template = GlobalIssueTemplate.new
    begin
      checklist_enabled = Redmine::Plugin.registered_plugins.keys.include? :redmine_checklists
    rescue
      checklist_enabled = false
    end
    if request.post?
      # Case post, set attributes passed as parameters.
      param_template = params[:global_issue_template]
      @global_issue_template.safe_attributes = param_template
      @global_issue_template.author = User.current

      checklists = param_template[:checklists]
      @global_issue_template.checklist_json = checklists.to_json if checklists

      save_and_flash && return
    end

    render(layout: !request.xhr?,
           locals: { checklist_enabled: checklist_enabled, trackers: trackers, apply_all_projects: apply_all_projects?,
                     issue_template: @global_issue_template, projects: projects }) && return
  end

  def show
    begin
      checklist_enabled = Redmine::Plugin.registered_plugins.keys.include? :redmine_checklists
    rescue
      checklist_enabled = false
    end
    projects = Project.all
    render(layout: !request.xhr?,
           locals: { checklist_enabled: checklist_enabled, trackers: @trackers, apply_all_projects: apply_all_projects?,
                     issue_template: @global_issue_template, projects: projects }) && return
  end

  def edit
    # Change from request.post to request.patch for Rails4.
    return unless request.patch? || request.put?
    param_template = params[:global_issue_template]
    @global_issue_template.safe_attributes = param_template

    checklists = param_template[:checklists]
    @global_issue_template.checklist_json = checklists.to_json if checklists
    save_and_flash
  end

  def destroy
    return unless request.post?
    return unless @global_issue_template.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index'
  end

  # preview
  def preview
    global_issue_template = params[:global_issue_template]
    id = params[:id]
    @text = (global_issue_template ? global_issue_template[:description] : nil)
    @global_issue_template = GlobalIssueTemplate.find(id) if id
    render partial: 'common/preview'
  end

  def move
    move_order(params[:to])
  end

  private

  def find_project
    @projects = Project.all
  end

  def find_object
    @trackers = Tracker.all
    @global_issue_template = GlobalIssueTemplate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def move_order(method)
    GlobalIssueTemplate.find(params[:id]).send "move_#{method}"
    render_for_move_with_format
  end

  def save_and_flash
    return unless @global_issue_template.save
    flash[:notice] = l(:notice_successful_create)
    redirect_to action: 'show', id: @global_issue_template.id
  end
end
