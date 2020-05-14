# frozen_string_literal: true

# noinspection RubocopInspection
class GlobalNoteTemplatesController < ApplicationController
  layout 'base'
  helper :issues
  helper :issue_templates
  menu_item :issues

  before_action :find_object, only: %i[show update destroy]
  before_action :find_project, only: %i[update]
  before_action :require_admin, only: %i[index new show], excep: [:preview]

  #
  # Action for global template : Admin right is required.
  #
  def index
    trackers = Tracker.all
    template_map = {}
    trackers.each do |tracker|
      tracker_id = tracker.id
      templates = GlobalNoteTemplate.search_by_tracker(tracker_id).sorted
      template_map[Tracker.find(tracker_id)] = templates if templates.any?
    end

    render layout: !request.xhr?, locals: { template_map: template_map, trackers: trackers }
  end

  def new
    # create empty instance
    @global_note_template = GlobalNoteTemplate.new
    render render_form_params
  end

  def create
    @global_note_template = GlobalNoteTemplate.new(template_params)
    @global_note_template.author = User.current

    save_and_flash(:notice_successful_create, :new) && return
  end

  def show
    render render_form_params
  end

  def update
    # Workaround in case author id is null
    @global_note_template.author = User.current if @global_note_template.author.blank?
    @global_note_template.safe_attributes = template_params

    save_and_flash(:notice_successful_update, :show)
  end

  def destroy
    unless @global_note_template.destroy
      flash[:error] = l(:enabled_template_cannot_destroy)
      redirect_to action: :show, id: @global_note_template
      return
    end

    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index'
  end

  def find_project
    @projects = Project.all
  end

  def find_object
    @global_note_template = GlobalNoteTemplate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def save_and_flash(message, action_on_failure)
    unless @global_note_template.save
      render render_form_params.merge(action: action_on_failure)
      return
    end

    respond_to do |format|
      format.html do
        flash[:notice] = l(message)
        redirect_to action: 'show', id: @global_note_template.id
      end
      format.js { head 200 }
    end
  end

  def template_params
    params.require(:global_note_template)
          .permit(:global_note_template_id, :tracker_id, :name, :memo, :description,
                  :enabled, :author_id, :position, :visibility, role_ids: [], project_ids: [])
  end

  def render_form_params
    trackers = Tracker.all
    projects = Project.all

    { layout: !request.xhr?,
      locals: { trackers: trackers, apply_all_projects: apply_all_projects?,
                note_template: @global_note_template, projects: projects } }
  end

  def apply_all_projects?
    plugin_setting['apply_global_template_to_all_projects'].to_s == 'true'
  end

  def plugin_setting
    Setting.plugin_redmine_issue_templates
  end
end
