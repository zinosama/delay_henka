module DelayHenka
  class ScheduledChange < ApplicationRecord
    self.ignored_columns = %w(
      submitted_by_id
    )

    STATES = {
      STAGED: 'staged',
      REPLACED: 'replaced',
      COMPLETED: 'completed',
      ERRORED: 'errored'
    }

    belongs_to :changeable, polymorphic: true

    validates :submitted_by_email, :attribute_name, presence: true
    validates :schedule_at, :time_zone, presence: true
    validates :state, inclusion: { in: STATES.values }
    after_initialize :set_initial_state, if: :new_record?

    scope :staged, -> { where(state: STATES[:STAGED]) }

    def self.schedule(record:, changes:, by_email:, schedule_at:, time_zone:)
      Keka.run do
        service = WhetherSchedule.new(record)
        new_changes = changes.each_with_object([]) do |(attribute, new_val), accum|
          old_val = record.public_send(attribute)
          cleaned_new_val = cleanup_val(new_val)
          decision = service.make_decision(attribute, cleaned_new_val)
          if decision.ok?
            accum << new(
              changeable: record,
              submitted_by_email: by_email,
              attribute_name: attribute,
              old_value: old_val,
              new_value: cleaned_new_val,
              schedule_at: schedule_at,
              time_zone: time_zone
            )
          elsif decision.msg
            return decision # error present
          else
            # otherwise do nothing - maybe no change is made
          end
        end

        transaction do
          new_changes.each(&:save!)
        end
      end
    end

    def apply_change
      if changeable
        if changeable.update(attribute_name => new_value)
          update!(state: STATES[:COMPLETED])
        else
          update!(state: STATES[:ERRORED], error_message: changeable.errors.full_messages.join(', '))
        end
      else
        update_columns(state: STATES[:ERRORED], error_message: 'Target record cannot be found')
      end
    end

    def replace_change
      update(state: STATES[:REPLACED])
    end

    private

    def self.cleanup_val(val)
      return val unless val.respond_to?(:strip)
      stripped = val.strip
      stripped == '' ? nil : stripped
    end

    def set_initial_state
      self.state ||= STATES[:STAGED]
    end

  end
end
