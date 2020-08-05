# frozen_string_literal: true

module Concerns
  module IssueTemplate
    module Common
      extend ActiveSupport::Concern

      #
      # Common scope both global and project scope template.
      #
      included do
        belongs_to :author, class_name: 'User', foreign_key: 'author_id'
        belongs_to :tracker
        before_save :check_default

        before_destroy :confirm_disabled

        validates :title, presence: true
        validates :tracker, presence: true
        validates :related_link, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true

        scope :enabled, -> { where(enabled: true) }
        scope :sorted, -> { order(:position) }
        scope :search_by_tracker, lambda { |tracker_id|
          where(tracker_id: tracker_id) if tracker_id.present?
        }

        scope :is_default, -> { where(is_default: true) }
        scope :not_default, -> { where(is_default: false) }

        scope :orphaned, lambda { |project_id = nil|
          condition = all
          if project_id.present? && try(:name) == 'IssueTemplate'
            condition = condition.where(project_id: project_id)
            ids = Tracker.joins(:projects).where(projects: { id: project_id }).pluck(:id)
          else
            ids = Tracker.pluck(:id)
          end
          condition.where.not(tracker_id: ids)
        }

        after_destroy do |template|
          logger.info("[Destroy] #{self.class}: #{template.inspect}")
        end

        # ActiveRecord::SerializationTypeMismatch may be thrown if non hash object is assigned.
        serialize :builtin_fields_json, Hash
      end

      #
      # Common methods both global and project scope template.
      #
      def enabled?
        enabled
      end

      def <=>(other)
        position <=> other.position
      end

      # Keep this method for a while, but this will be deprecated.
      # Please see: https://github.com/akiko-pusu/redmine_issue_templates/issues/363
      def checklist
        return [] if checklist_json.blank?

        begin
          JSON.parse(checklist_json)
        rescue StandardError
          []
        end
      end

      def template_json(except: nil)
        template = {}
        template[self.class::Config::JSON_OBJECT_NAME] = generate_json
        return template.to_json(root: true) if except.blank?

        template.to_json(root: true, except: [except])
      end

      def builtin_fields
        builtin_fields_json.to_json
      end

      def generate_json
        result = attributes
        result[:link_title] = link_title.presence || I18n.t(:issue_template_related_link, default: 'Related Link')
        result[:checklist] = checklist
        result.except('checklist_json')
      end

      def template_struct(option = {})
        Struct.new(:value, :name, :class, :selected).new(id, title, option[:class])
      end

      def log_destroy_action(template)
        logger.info "[Destroy] #{self.class}: #{template.inspect}" if logger&.info
      end

      def confirm_disabled
        return unless enabled?

        errors.add :base, 'enabled_template_cannot_destroy'
        throw :abort
      end

      def copy_title
        "copy_of_#{title}"
      end
    end
  end
end
