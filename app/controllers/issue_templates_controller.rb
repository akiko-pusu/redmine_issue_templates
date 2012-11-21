class IssueTemplatesController < ApplicationController
  unloadable
  layout 'base'
  include IssueTemplatesHelper
  helper :issues
  include IssuesHelper
  menu_item :issues
  before_filter :find_object, :only => [ :show, :edit, :destroy ]
  before_filter :find_user, :find_project, :authorize, 
    :except => [ :preview, :move_order_higher, :move_order_lower, 
                 :move_order_to_top, :move_order_to_bottom, :move ]
  before_filter :find_tracker, :only => [ :set_pulldown ]

  def index
    @template_map = Hash::new
    @project.trackers.each do |tracker| 
      templ = IssueTemplate.find(:all, 
        :conditions => ['project_id = ? AND tracker_id = ?', 
        @project.id, tracker.id],:order => 'position')
      if templ.any?
        @template_map[tracker] = templ
      end
    end
    @issue_templates = IssueTemplate.find(:all, 
      :conditions => ['project_id = ?', @project.id], 
      :order => 'position')
    
    render :template => 'issue_templates/index.html.erb', :layout => !request.xhr? 
  end

  def show
  end

  def new
    # create empty instance
    @issue_template = IssueTemplate.new(:author => @user, :project => @project, 
      :tracker => @tracker)
    if request.post?
      # Case post, set attributes passed as parameters.
      @issue_template.safe_attributes = params[:issue_template]
      if @issue_template.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to :action => "show", :id => @issue_template.id, 
          :project_id => @project
      end
    end
  end

  def edit
    if request.put?
      @issue_template.safe_attributes = params[:issue_template]
      if @issue_template.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => "show", :id => @issue_template.id, 
          :project_id => @project
      end
    end
  end

  def destroy
    if request.post?
      if @issue_template.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to :action => "index", :project_id => @project
      end
    end
  end

  # load template description
  def load
    @issue_template = IssueTemplate.find(params[:issue_template])
    render :text => @issue_template.to_json
  end
  
  # update pulldown
  def set_pulldown
    issue_templates = IssueTemplate.find(:all, 
      :conditions => ['project_id = ? AND tracker_id = ?', 
      @project.id, @tracker.id],:order => 'position')
    @grouped_options = []
    group = []
    if issue_templates.size > 0
      issue_templates.each { |x| group.push([x.title, x.id]) }
      @grouped_options.push([@tracker.name, group])
    end      
    render :action => "_template_pulldown", :layout => false
    #render :action => "issue_templates/_template_pulldown", :layout => false
  end

  # preview
  def preview
    @text = (params[:issue_template] ? params[:issue_template][:description] : nil)
    @issue_template = IssueTemplate.find(params[:id]) if params[:id]
    render :partial => 'common/preview'
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
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  def move_order(method)
    IssueTemplate.find(params[:id]).send "move_#{method}"
    #flash[:notice] = l(:notice_successful_reorder_template)
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
    end
  end
end

