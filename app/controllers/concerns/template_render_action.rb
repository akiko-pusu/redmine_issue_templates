module Concerns
  module TemplateRenderAction
    extend ActiveSupport::Concern
    unloadable
    def render_for_move_with_format
      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.xml  { head :ok }
      end
    end

    def plugin_setting
      @plugin_setting ||= Setting.plugin_redmine_issue_templates
    end

    def apply_all_projects?
      plugin_setting['apply_global_template_to_all_projects'] == 'true'
    end
  end
end
