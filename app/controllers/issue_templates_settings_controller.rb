# frozen_string_literal: true

# noinspection RubocopInspection
class IssueTemplatesSettingsController < ApplicationController
  before_action :find_project, :find_user
  before_action :authorize, :find_issue_templates_setting, except: %i[preview]

  def index; end

  def edit
    return if params[:settings].blank?

    update_template_setting
    flash[:notice] = l(:notice_successful_update)
    redirect_to action: 'index', project_id: @project
  end

  def preview
    @text = params[:settings][:help_message]
    render partial: 'common/preview'
  end

  def menu_items
    { issue_templates_settings: { default: :issue_templates, actions: {} } }
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

  def find_issue_templates_setting
    @issue_templates_setting = IssueTemplateSetting.find_or_create(@project.id)
  end

  def update_template_setting
    issue_templates_setting = IssueTemplateSetting.find_or_create(@project.id)
    attribute = params[:settings]
    issue_templates_setting.update(enabled: attribute[:enabled],
                                   help_message: attribute[:help_message],
                                   inherit_templates: attribute[:inherit_templates],
                                   should_replaced: attribute[:should_replaced])
  end
end
