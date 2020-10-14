class AddScheduledActionsSubmittedByEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :delay_henka_scheduled_actions, :submitted_by_email, :string
  end
end
