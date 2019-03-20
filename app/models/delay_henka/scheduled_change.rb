# == Schema Information
#
# Table name: delay_henka_scheduled_changes
#
#  id              :bigint(8)        not null, primary key
#  changeable_type :string           not null
#  changeable_id   :integer          not null
#  attribute_name  :string           not null
#  submitted_by_id :integer          not null
#  state           :string           not null
#  error_message   :text
#  old_value       :jsonb
#  new_value       :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  schedule_at     :datetime         not null
#  action_type     :string           default("update"), not null
#

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
    validates :schedule_at, presence: true
    validates :state, inclusion: { in: STATES.values }
    after_initialize :set_initial_state, if: :new_record?

    scope :staged, -> { where(state: STATES[:STAGED]) }

    def self.schedule(record:, changes:, by_id:, schedule_at: Time.current)
      changes.each do |attribute, new_val|
        old_val = record.public_send(attribute)
        cleaned_new_val = cleanup_val(new_val)
        record.public_send("#{attribute}=", cleaned_new_val)
        next unless record.public_send("#{attribute}_changed?")
        create!(changeable: record, submitted_by_id: by_id, attribute_name: attribute, old_value: old_val, new_value: cleaned_new_val, schedule_at: schedule_at)
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
