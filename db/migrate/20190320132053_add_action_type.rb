class AddActionType < ActiveRecord::Migration[5.2]
  def change
    add_column :delay_henka_scheduled_changes, :action_type, :string, default: 'update', null: false, index: true
  end
end
