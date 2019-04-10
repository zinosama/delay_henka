class CreateDelayHenkaScheduledActions < ActiveRecord::Migration[5.2]
  def change
    create_table :delay_henka_scheduled_actions do |t|
      t.references :actionable, polymorphic: true, null: false, index: { name: 'actionable_index' }
      t.string :method_name, null: false
      t.string :state, null: false, index: true
      t.string :error_message
      t.integer :submitted_by_id, null: false
      t.datetime :schedule_at, index: true, null: false
      t.jsonb :argument
      t.jsonb :return_value
      t.timestamps
    end
  end
end
