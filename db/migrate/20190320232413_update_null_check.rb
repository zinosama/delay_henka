class UpdateNullCheck < ActiveRecord::Migration[5.2]
  def change
    change_column_null :delay_henka_scheduled_changes, :changeable_id, true
    change_column_null :delay_henka_scheduled_changes, :attribute_name, true
  end
end
