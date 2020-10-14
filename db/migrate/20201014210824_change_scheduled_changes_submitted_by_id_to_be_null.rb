class ChangeScheduledChangesSubmittedByIdToBeNull < ActiveRecord::Migration[5.2]
  def up
    change_column_null :delay_henka_scheduled_changes, :submitted_by_id, true
  end

  def down
    # NOTE: Nil values may now existing in the database preventing this from
    # rolling back. If you would like to reverse this migration, please create a
    # new migration to do so after adding a one-off rake task or data migration
    # to resolve nil values.
    raise ActiveRecord::IrreversibleMigration
  end
end
