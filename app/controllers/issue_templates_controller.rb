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
    tracker_ids = IssueTemplate.where('project_id = ?', @project.id).pluck(:tracker_id)

    @template_map = Hash::new
    tracker_ids.each do |tracker_id|
      templates = IssueTemplate.where('project_id = ? AND tracker_id = ?',
                                              @project.id, tracker_id).order('position')
      if templates.any?
        @template_map[Tracker.find(tracker_id)] = templates
      end
    end

    @issue_templates = IssueTemplate.where('project_id = ?',
                          @project.id).order('position')

    @setting = IssueTemplateSetting.find_or_create(@project.id)
    inherit_template = @setting.enabled_inherit_templates?
    @inherit_templates = []

    project_ids = inherit_template ? @project.ancestors.collect(&:id) : [@project.id]
    if inherit_template
      # keep ordering
      used_tracker_ids = @project.trackers.pluck(:tracker_id)

      project_ids.each do |i|
        @inherit_templates.concat(IssueTemplate.where('project_id = ? AND enabled = ?
          AND enabled_sharing = ? AND tracker_id IN (?)', i, true, true, used_tracker_ids).order('position'))
      end
    end

    @globalIssueTemplates = GlobalIssueTemplate.find(:all,:include => [:projects],
                                                      :conditions => ["projects.id = ?", @project.id] )

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
    if params[:template_type] != nil && params[:template_type]== 'global'
      @issue_template = GlobalIssueTemplate.find(params[:issue_template])
    else
      @issue_template = IssueTemplate.find(params[:issue_template])
    end
    render :text => @issue_template.to_json
  end
  
  # update pulldown
  def set_pulldown
    @grouped_options = []
    group = []
    @default_template = nil
    @setting = IssueTemplateSetting.find_or_create(@project.id)
    inherit_template = @setting.enabled_inherit_templates?

    project_ids = inherit_template ? @project.ancestors.collect(&:id) : [@project.id]
    issue_templates = IssueTemplate.where('project_id = ? AND tracker_id = ? AND enabled = ?',
                                          @project.id, @tracker.id, true).order('position')

    project_default_template = IssueTemplate.where('project_id = ? AND tracker_id = ? AND enabled = ?
                                     AND is_default = ?',
                                                  @project.id, @tracker.id, true, true).first

    unless project_default_template.blank?
       @default_template = project_default_template
    end

    if issue_templates.size > 0
      issue_templates.each { |x| group.push([x.title, x.id]) }
    end

    if inherit_template
      inherit_templates = []

      # keep ordering of project tree
       # TODO: Add Test code.
       project_ids.each do |i|
        inherit_templates.concat(IssueTemplate.where('project_id = ? AND tracker_id = ? AND enabled = ?
          AND enabled_sharing = ?', i, @tracker.id, true, true).order('position'))
      end

      if inherit_templates.any?
        inherit_templates.each do |x|
          group.push([x.title, x.id, {:class => "inherited"}])
          if x.is_default == true
             if project_default_template.blank?
              @default_template = x
            end
          end
        end
      end
    end

    @globalIssueTemplates = GlobalIssueTemplate.find(:all,:include => [:projects],
                                                     :conditions => [" tracker_id = ? AND projects.id = ?", @tracker.id, @project.id] )
    if @globalIssueTemplates.any?
      @globalIssueTemplates.each do |x|
        group.push([x.title, x.id, {:class => "global"}])
        # Using global template as default template is now disabled.
        # if x.is_default == true
        #   if project_default_template.blank?
        #     @default_template = x
        #   end
        # end
      end
    end

    @grouped_options.push([@tracker.name, group]) if group.any?
    render :action => "_template_pulldown", :layout => false
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
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
    end
  end
end

