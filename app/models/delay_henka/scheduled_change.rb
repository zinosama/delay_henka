module DelayHenka
  class ScheduledChange < ApplicationRecord

    STATES = {
      STAGED: 'staged',
      REPLACED: 'replaced',
      COMPLETED: 'completed',
      ERRORED: 'errored'
    }

    belongs_to :changeable, polymorphic: true

    validates :submitted_by_id, :attribute_name, presence: true
    validates :state, inclusion: { in: STATES.values }
    after_initialize :set_initial_state, if: :new_record?

    scope :staged, -> { where(state: STATES[:STAGED]) }

    def self.schedule(record:, changes:, by_id:)
      changes.each do |attribute, new_val|
        old_val = record.public_send(attribute)
        cleaned_new_val = cleanup_val(new_val)
        next if old_val == cleaned_new_val
        create!(changeable: record, submitted_by_id: by_id, attribute_name: attribute, old_value: old_val, new_value: cleaned_new_val)
      end
    end

    def apply_change
      if changeable
        if changeable.update(attribute_name => new_value)
          update(state: STATES[:COMPLETED])
        else
          update(state: STATES[:ERRORED], error_message: changeable.errors.full_messages.join(', '))
        end
      else
        update(state: STATES[:ERRORED], error_message: 'Target record cannot be found')
      end
    end

    def replace_change
      update(state: STATES[:REPLACED])
    end

    private

    def self.cleanup_val(val)
      return val unless val.respond_to?(:strip)
      val.strip == '' ? nil : val
    end

    def set_initial_state
      self.state ||= STATES[:STAGED]
    end

  end
end
