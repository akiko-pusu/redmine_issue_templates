class NoteTemplatesController < ApplicationController
  layout 'base'
  menu_item :issues
  before_action :find_object, only: %i[show update destroy]
  before_action :find_user, :find_project, :authorize, except: [:preview]
  accept_api_auth :index, :load

  def index
    project_id = @project.id
    note_templates = NoteTemplate.search_by_project(project_id)

    # pick up used tracker ids
    tracker_ids = @project.trackers.pluck(:id)

    @note_template_map = {}
    tracker_ids.each do |tracker_id|
      templates = note_templates.search_by_tracker(tracker_id)
      @note_template_map[Tracker.find(tracker_id)] = templates if templates.any?
    end

    respond_to do |format|
      format.html do
        render layout: !request.xhr?
      end
      format.api do
        render formats: :json, locals: {note_templates: note_templates}
      end
    end
  end

  private

  def find_user
    @user = User.current
  end

  def find_tracker
    @tracker = Tracker.find(params[:issue_tracker_id])
  end

  def find_object
    @note_template = NoteTemplate.find(params[:id])
    @project = @note_template.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
