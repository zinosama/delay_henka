class AddTimeZoneAndServiceRegionToChangesAndActions < ActiveRecord::Migration[5.2]
  def change
    add_column :delay_henka_scheduled_changes, :time_zone, :string
    add_column :delay_henka_scheduled_changes, :service_region_id, :integer

    add_column :delay_henka_scheduled_actions, :time_zone, :string
    add_column :delay_henka_scheduled_actions, :service_region_id, :integer
  end
end
