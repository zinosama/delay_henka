class CreateDelayHenkaScheduledChanges < ActiveRecord::Migration[5.2]
  def change
    create_table :delay_henka_scheduled_changes do |t|
      t.string :changeable_type, null: false
      t.integer :changeable_id, null: false
      t.string :attribute_name, null: false
      t.integer :submitted_by_id, null: false
      t.string :state, null: false
      t.text :error_message
      t.jsonb :old_value
      t.jsonb :new_value
      t.timestamps
    end
  end
end
