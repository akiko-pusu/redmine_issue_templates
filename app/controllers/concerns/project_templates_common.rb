module Concerns
  module ProjectTemplatesCommon
    extend ActiveSupport::Concern
    included do
      before_action :find_user, :find_project, :authorize, except: [:preview]
      before_action :find_object, only: %i[show edit update destroy]
      accept_api_auth :index, :list_templates, :load
    end

    def show
      render render_form_params
    end

    def destroy
      unless template.destroy
        flash[:error] = l(:enabled_template_cannot_destroy)
        redirect_to action: :show, project_id: @project, id: template
        return
      end
  
      flash[:notice] = l(:notice_successful_delete)
      redirect_to action: 'index', project_id: @project
    end

    def save_and_flash(message, action_on_failure)
      unless template.save
        render render_form_params.merge(action: action_on_failure)
        return
      end

      respond_to do |format|
        format.html do
          flash[:notice] = l(message)
          redirect_to action: 'show', id: template.id, project_id: @project
        end
        format.js { head 200 }
      end
    end

    private

    def template
      raise NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def find_user
      @user = User.current
    end

    def find_tracker
      @tracker = Tracker.find(params[:issue_tracker_id])
    end

    def find_project
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def render_form_params
      { layout: !request.xhr?,
        locals: { checklist_enabled: checklist_enabled?,
                  issue_template: template, project: @project } }
    end
  end
end
