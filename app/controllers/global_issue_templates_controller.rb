# noinspection RubocopInspection
class GlobalIssueTemplatesController < ApplicationController
  unloadable
  layout 'base'
  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  menu_item :issues
  before_filter :find_object, only: [:show, :edit, :destroy]
  before_filter :find_project, only: [:edit]
  before_filter :require_admin, :find_user, only: [:index, :new, :show], excep: [:preview]

  #
  # Action for global template : Admin right is required.
  #
  def index
    @trackers = Tracker.all
    @template_map = {}
    @trackers.each do |tracker|
      templates = GlobalIssueTemplate.where('tracker_id = ?', tracker.id).order('position')
      @template_map[Tracker.find(tracker.id)] = templates if templates.any?
    end
    render layout: !request.xhr?
  end

  def new
    # create empty instance
    @trackers = Tracker.all
    @projects = Project.all
    @global_issue_template = GlobalIssueTemplate.new(author: @user, tracker: @tracker)
    if request.post?
      # Case post, set attributes passed as parameters.
      @global_issue_template.safe_attributes = params[:global_issue_template]
      if @global_issue_template.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to action: 'show', id: @global_issue_template.id
      end
    end
  end

  def show
    @projects = Project.all
  end

  def edit
    # Change from request.post to request.patch for Rails4.
    if request.patch? || request.put?
      @global_issue_template.safe_attributes = params[:global_issue_template]
      if @global_issue_template.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to action: 'show', id: @global_issue_template.id
      else
        respond_to do |format|
          format.html { render action: 'show' }
        end
      end
    end
  end

  def destroy
    if request.post?
      if @global_issue_template.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to action: 'index'
      end
    end
  end

  # preview
  def preview
    @text = (params[:global_issue_template] ? params[:global_issue_template][:description] : nil)
    @global_issue_template = GlobalIssueTemplate.find(params[:id]) if params[:id]
    render partial: 'common/preview'
  end

  def move
    move_order(params[:to])
  end

  private

  # Reorder templates
  def find_user
    @user = User.current
  end

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
    respond_to do |format|
      format.html { redirect_to action: 'index' }
      format.xml  { head :ok }
    end
  end
end
