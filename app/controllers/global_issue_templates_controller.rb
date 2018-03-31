# noinspection RubocopInspection
class GlobalIssueTemplatesController < ApplicationController
  layout 'base'
  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  include Concerns::IssueTemplatesCommon
  menu_item :issues
  before_filter :find_object, only: [:show, :edit, :update, :destroy]
  before_filter :find_project, only: [:edit, :update]
  before_filter :require_admin, only: [:index, :new, :show], excep: [:preview]

  #
  # Action for global template : Admin right is required.
  #
  def index
    trackers = Tracker.all
    template_map = {}
    trackers.each do |tracker|
      tracker_id = tracker.id
      templates = GlobalIssueTemplate.search_by_tracker(tracker_id).sorted
      template_map[Tracker.find(tracker_id)] = templates if templates.any?
    end
    render layout: !request.xhr?, locals: { template_map: template_map, trackers: trackers }
  end

  def new
    # create empty instance
    @global_issue_template = GlobalIssueTemplate.new

    if request.post?
      # Case post, set attributes passed as parameters.
      @global_issue_template.safe_attributes = template_params
      @global_issue_template.author = User.current
      @global_issue_template.checklist_json = checklists.to_json if checklists

      save_and_flash(:notice_successful_create) && return
    end

    render_form
  end

  def show
    render_form
  end

  def update
    @global_issue_template.safe_attributes = template_params
    @global_issue_template.checklist_json = checklists.to_json
    save_and_flash(:notice_successful_update)
  end

  def edit
    # Change from request.post to request.patch for Rails4.
    return unless request.patch? || request.put?
    @global_issue_template.safe_attributes = template_params
    @global_issue_template.checklist_json = checklists.to_json
    save_and_flash(:notice_successful_update)
  end

  def destroy
    return unless request.post?
    unless @global_issue_template.destroy
      flash[:error] = l(:enabled_template_cannot_destroy)
      redirect_to action: :show, id: @global_issue_template
      return
    end
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

  def orphaned_templates
    orphaned = GlobalIssueTemplate.orphaned
    render partial: 'orphaned_templates', locals: { orphaned_templates: orphaned }
  end

  private

  def find_project
    @projects = Project.all
  end

  def find_object
    @global_issue_template = GlobalIssueTemplate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def save_and_flash(message)
    return unless @global_issue_template.save
    respond_to do |format|
      format.html do
        flash[:notice] = l(message)
        redirect_to action: 'show', id: @global_issue_template.id
      end
      format.js { head 200 }
    end
  end

  def template_params
    params.require(:global_issue_template)
          .permit(:title, :tracker_id, :issue_title, :description, :note, :is_default, :enabled,
                  :author_id, :position, project_ids: [], checklists: [])
  end

  def render_form
    trackers = Tracker.all
    projects = Project.all
    render(layout: !request.xhr?,
           locals: { checklist_enabled: checklist_enabled?, trackers: trackers, apply_all_projects: apply_all_projects?,
                     issue_template: @global_issue_template, projects: projects })
  end
end
