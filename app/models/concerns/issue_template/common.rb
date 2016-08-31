module Concerns
  module IssueTemplate
    module Common
      extend ActiveSupport::Concern

      #
      # Common scope both global and project scope template.
      #
      included do
        scope :enabled, -> { where(enabled: true) }
        scope :order_by_position, -> { order(:position) }
        scope :search_by_tracker, lambda { |tracker_id|
          where(tracker_id: tracker_id) if tracker_id.present?
        }
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
    end
  end
end
