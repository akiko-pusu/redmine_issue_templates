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

      def plugin_setting
        Setting.plugin_redmine_issue_templates
      end

      def apply_all_projects?
        plugin_setting['apply_global_template_to_all_projects'].to_s == 'true'
      end

      def apply_template_when_edit_issue?
        plugin_setting['apply_template_when_edit_issue'].to_s == 'true'
      end

      def builtin_fields_enabled?
        plugin_setting['enable_builtin_fields'].to_s == 'true'
      end
    end

    def load_selectable_fields
      tracker_id = params[:tracker_id]
      render plain: {} && return if tracker_id.blank?

      custom_fields = core_fields_map_by_tracker_id(tracker_id).merge(custom_fields_map_by_tracker_id(tracker_id))
      render plain: { custom_fields: custom_fields }.to_json
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
      attributes[:builtin_fields_json] = builtin_fields_json if builtin_fields_enabled?
      attributes[:checklist_json] = checklists.to_json if checklist_enabled?
      attributes
    end

    def destroy
      raise NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def core_fields_map_by_tracker_id(tracker_id = nil)
      return {} unless builtin_fields_enabled?

      fields = %w[status_id priority_id]

      # exclude "description"
      tracker = Tracker.find_by(id: tracker_id)
      fields += tracker.core_fields.reject { |field| field == 'description' } if tracker.present?

      map = {}
      fields.each do |field|
        id = "issue_#{field}"
        name = I18n.t('field_' + field.gsub(/_id$/, ''))
        map[id] = name
      end
      map
    end

    def custom_fields_map_by_tracker_id(tracker_id = nil)
      return {} unless builtin_fields_enabled?
      return {} if tracker_id.blank?

      tracker = Tracker.find_by(id: tracker_id)
      ids = tracker&.custom_field_ids || []
      fields = IssueCustomField.where(id: ids)
      map = {}
      fields.each do |field|
        id = "issue_custom_field_values_#{field.id}"
        name = field.name
        map[id] = name
      end
      map
    end
  end
end
