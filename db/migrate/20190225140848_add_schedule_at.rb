class AddScheduleAt < ActiveRecord::Migration[5.2]
  def change
    add_column :delay_henka_scheduled_changes, :schedule_at, :datetime, null: false
  end
end
