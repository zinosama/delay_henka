module DelayHenka
  class ScheduledAction < ApplicationRecord

    STATES = {
      STAGED: 'staged',
      COMPLETED: 'completed',
    }

    belongs_to :actionable, polymorphic: true

    validates :submitted_by_id, presence: true
    validates :schedule_at, presence: true
    validates :state, inclusion: { in: STATES.values }
    after_initialize :set_initial_state, if: :new_record?

    scope :staged, -> { where(state: STATES[:STAGED]) }

    def self.schedule(record:, method_name:, arguments:, by_id:, schedule_at: Time.current)
      DelayHenka::ScheduledAction.create(
        actionable: record,
        method_name: method_name,
        arguments: arguments,
        submitted_by_id: by_id,
        schedule_at: schedule_at
      )
    end

    def apply_action
      if actionable
        update(state: STATES[:COMPLETED])
        actionable.send(method_name, *arguments)
      else
        update(state: STATES[:ERRORED], error_message: 'Target record cannot be found')
      end
    end

    private

    def set_initial_state
      self.state ||= STATES[:STAGED]
    end

  end
end
