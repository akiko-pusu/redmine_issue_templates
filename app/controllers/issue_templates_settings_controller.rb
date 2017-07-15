# noinspection RubocopInspection
class IssueTemplatesSettingsController < ApplicationController
  before_filter :find_project, :find_user
  before_filter :authorize, except: [:show_help, :preview]

  def edit
    return if params[:settings].blank?
    update_template_setting
    flash[:notice] = l(:notice_successful_update)
    redirect_to controller: 'projects', action: 'settings', id: @project, tab: 'issue_templates'
  end

  def preview
    @text = params[:settings][:help_message]
    render partial: 'common/preview'
  end

  private

  def find_user
    @user = User.current
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update_template_setting
    issue_templates_setting = IssueTemplateSetting.find_or_create(@project.id)
    attribute = params[:settings]
    issue_templates_setting.update_attributes(enabled: attribute[:enabled],
                                              help_message: attribute[:help_message],
                                              inherit_templates: attribute[:inherit_templates],
                                              should_replaced: attribute[:should_replaced])
  end
end
