namespace :one_off do
  desc 'Copy submitted_by_id.email to submitted_by_email attribute of DelayHenka::ScheduledAction'
  task bac_2434_backfill_delay_henka_scheduled_actions_submitted_by_email: :environment do
    batch_size = ENV['BATCH_SIZE'] || 1000
    total_updated = 0
    update_query = <<-SQL.strip.squish
      UPDATE delay_henka_scheduled_actions
      SET submitted_by_email = users.email
      FROM users
      WHERE delay_henka_scheduled_actions.submitted_by_id = users.id AND
        delay_henka_scheduled_actions.id IN (SELECT id from delay_henka_scheduled_actions
          WHERE submitted_by_email IS NULL AND
            submitted_by_id IS NOT NULL
          LIMIT #{batch_size}
        )
    SQL

    while (updated_count = ActiveRecord::Base.connection.update(update_query)) > 0
      total_updated += updated_count
      puts "\nupdated the batch of #{updated_count} rows\n"
    end

    puts "\nfinished updating DelayHenka::ScheduledAction submitted_by emails. #{total_updated} rows were updated\n\n"
  end
end
