class AddScheduledChangesSubmittedByEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :delay_henka_scheduled_changes, :submitted_by_email, :string
  end
end
