class DeprecateScheduledActionsScheduledChangesSubmittedById < ActiveRecord::Migration[5.2]
  def change
    change_column_comment :delay_henka_scheduled_changes, :submitted_by_id, from: nil, to: 'Legacy. Deprecated in favor of submitted_by_email, which stores just an email'
    change_column_comment :delay_henka_scheduled_actions, :submitted_by_id, from: nil, to: 'Legacy. Deprecated in favor of submitted_by_email, which stores just an email'
  end
end
