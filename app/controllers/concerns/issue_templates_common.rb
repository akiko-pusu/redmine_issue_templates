module Concerns
  module IssueTemplatesCommon
    extend ActiveSupport::Concern
    included do
      before_action :log_action, only: [:destroy]

      # logging action
      def log_action
        logger.info "[#{self.class}] #{action_name} called by #{User.current.name}" if logger
      end
    end

    def plugin_setting
      @plugin_setting ||= Setting.plugin_redmine_issue_templates
    end

    def apply_all_projects?
      plugin_setting['apply_global_template_to_all_projects'].to_s == 'true'
    end

    def checklists
      template_params[:checklists].blank? ? {} : template_params[:checklists]
    end

    def checklist_enabled?
      Redmine::Plugin.registered_plugins.keys.include? :redmine_checklists
    rescue
      false
    end
  end
end
