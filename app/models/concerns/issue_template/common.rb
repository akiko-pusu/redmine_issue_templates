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

        # FIXME: Porting a part of lib/redmine/acts/positioned.rb, in order to support
        #    Redmine 3.0 to 3.4 compatibility
        # Ref: https://github.com/akiko-pusu/redmine_issue_templates/issues/180
        #
        before_save :set_default_position
        after_save :update_position
        after_destroy :remove_position

        validates :title, presence: true
        validates :tracker, presence: true

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

      def checklist
        return [] if checklist_json.blank?
        begin
          JSON.parse(checklist_json)
        rescue
          []
        end
      end

      def template_json
        template = {}
        template[self.class::Config::JSON_OBJECT_NAME] = generate_json
        template.to_json(root: true)
      end

      def generate_json
        result = attributes
        result[:checklist] = checklist
        result.except('checklist_json')
      end

      def template_struct(option = {})
        Struct.new(:value, :name, :class, :selected).new(id, title, option[:class])
      end

      def log_destroy_action(template)
        logger.info "[Destroy] #{self.class}: #{template.inspect}" if logger && logger.info
      end

      def confirm_disabled
        return unless enabled?
        errors.add :base, 'enabled_template_cannot_destroy'
        false
      end

      def copy_title
        "copy_of_#{title}"
      end

      private

      # NOTE: set_default_position to reset_positions_in_list should be removed when this plugin's target Redmine
      #   version is changed to Redmine4.
      def set_default_position
        return unless position.nil?
        self.position = self.class.where(tracker_id: tracker_id).maximum(:position).to_i + (new_record? ? 1 : 0)
      end

      def update_position
        position_scope_changed = (changed & ['tracker_id']).any?
        if !new_record? && position_scope_changed
          remove_position
          insert_position
        elsif position_changed?
          position_was.nil? ? insert_position : shift_positions
        end
      end

      def remove_position
        self.class.where(tracker_id: tracker_id_was).where('position >= ? AND id <> ?', position_was, id).update_all('position = position - 1')
      end

      def insert_position
        self.class.where(tracker_id: tracker_id).where('position >= ? AND id <> ?', position, id).update_all('position = position + 1')
      end

      def shift_positions
        offset = position_was <=> position
        min, max = [position, position_was].sort
        r = self.class.where(tracker_id: tracker_id).where('id <> ? AND position BETWEEN ? AND ?', id, min, max)
                .update_all(['position = position + ?', offset])
        reset_positions_in_list if r != max - min
      end

      def reset_positions_in_list
        self.class.where(tracker_id: tracker_id).reorder(:position, :id).pluck(:id).each_with_index do |record_id, p|
          self.class.where(id: record_id).update_all(position: p + 1)
        end
      end
    end
  end
end
