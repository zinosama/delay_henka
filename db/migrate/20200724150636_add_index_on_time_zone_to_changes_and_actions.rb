class AddIndexOnTimeZoneToChangesAndActions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :delay_henka_scheduled_changes, :time_zone, algorithm: :concurrently
    add_index :delay_henka_scheduled_actions, :time_zone, algorithm: :concurrently
  end
end
