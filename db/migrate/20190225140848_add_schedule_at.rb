class AddScheduleAt < ActiveRecord::Migration[5.2]
  def change
    add_column :delay_henka_scheduled_changes, :schedule_at, :datetime
    DelayHenka::ScheduledChange.where(schedule_at: nil).update_all('schedule_at = created_at')
    change_column_null :delay_henka_scheduled_changes, :schedule_at, false
  end
end
