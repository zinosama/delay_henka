module DelayHenka
  class ScheduledAction < ApplicationRecord
    self.ignored_columns = %w(
      submitted_by_id
    )

    STATES = {
      STAGED: 'staged',
      COMPLETED: 'completed',
      ERRORED: 'errored'
    }

    belongs_to :actionable, polymorphic: true

    validates :submitted_by_email, :schedule_at, :time_zone, presence: true
    validates :state, inclusion: { in: STATES.values }
    after_initialize :set_initial_state, if: :new_record?

    scope :staged, -> { where(state: STATES[:STAGED]) }

    def self.schedule(record:, method_name:, argument: nil, by_email:, schedule_at:, time_zone:)
      Keka.run do
        begin
          arity = record.method(method_name.to_sym).arity
          Keka.err_unless! (arity == 0 && argument.nil?) || (arity == 1 && !argument.nil?), 'wrong arity'
          DelayHenka::ScheduledAction.create(
            actionable: record,
            method_name: method_name,
            argument: argument.to_json,
            submitted_by_email: by_email,
            schedule_at: schedule_at,
            time_zone: time_zone
          )
        rescue NameError => e
          Keka.err_if! true, e.message
        end
      end
    end

    def apply_action
      unless actionable
        # Caution: model validations are bypassed
        update_columns(state: STATES[:ERRORED], error_message: 'Target record cannot be found')
        return
      end

      begin
        output = actionable.method(method_name.to_sym).arity == 0 ?
          actionable.send(method_name) :
          actionable.send(method_name, JSON.parse(argument))
        update!(state: STATES[:COMPLETED], return_value: output.to_json)
      rescue => e
        update!(state: STATES[:ERRORED], error_message: e.message)
        raise e
      end
    end

    private

    def set_initial_state
      self.state ||= STATES[:STAGED]
    end

  end
end
