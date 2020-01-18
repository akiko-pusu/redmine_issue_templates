# frozen_string_literal: true

module Concerns
  module IssueTemplatesCommon
    extend ActiveSupport::Concern

    class InvalidTemplateFormatError < StandardError; end

    included do
      before_action :log_action, only: [:destroy]

      # logging action
      def log_action
        logger&.info "[#{self.class}] #{action_name} called by #{User.current.name}"
      end
    end

    def orphaned_templates
      render partial: 'common/orphaned', locals: { orphaned_templates: orphaned }
    end

    def plugin_setting
      @plugin_setting ||= Setting.plugin_redmine_issue_templates
    end

    def apply_all_projects?
      plugin_setting['apply_global_template_to_all_projects'].to_s == 'true'
    end

    def checklists
      template_params[:checklists].presence || []
    end

    def builtin_fields_json
      value = template_params[:builtin_fields].blank? ? {} : JSON.parse(template_params[:builtin_fields])
      return value if value.is_a?(Hash)

      raise InvalidTemplateFormatError
    end

    def checklist_enabled?
      Redmine::Plugin.registered_plugins.key? :redmine_checklists
    rescue StandardError
      false
    end

    def valid_params
      # convert attribute name and data for checklist plugin supporting
      attributes = template_params.except(:checklists, :builtin_fields)
      attributes[:builtin_fields_json] = builtin_fields_json
      attributes[:checklist_json] = checklists.to_json if checklist_enabled?
      attributes
    end

    def destroy
      raise NotImplementedError, "You must implement #{self.class}##{__method__}"
    end
  end
end
