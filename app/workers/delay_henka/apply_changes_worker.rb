module DelayHenka
  class ApplyChangesWorker

    include Sidekiq::Worker

    def perform
      ScheduledChange.staged.update_action
        .where('schedule_at <= ?', Time.current)
        .includes(:changeable)
        .group_by{ |change| [change.changeable_type, change.changeable_id, change.attribute_name] }
        .values
        .each do |changes_for_attribute|
          latest_change = changes_for_attribute.sort_by(&:created_at).last
          (changes_for_attribute - [latest_change]).each(&:replace_change)
          latest_change.apply_change
      end

      ScheduledChange.staged.create_action
        .where('schedule_at <= ?', Time.current)
        .order(:created_at).find_each do |scheduled_change|
          scheduled_change.apply_create
      end
    end

  end
end
