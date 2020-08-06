module DelayHenka
  class ApplyChangesWorker

    include Sidekiq::Worker

    def perform(time_zone)
      ScheduledChange.staged
        .where('schedule_at <= ?', Time.current)
        .where(time_zone: time_zone)
        .includes(:changeable)
        .group_by{ |change| [change.changeable_type, change.changeable_id, change.attribute_name] }
        .values
        .each do |changes_for_attribute|
          latest_change = changes_for_attribute.sort_by(&:created_at).last
          (changes_for_attribute - [latest_change]).each(&:replace_change)
          latest_change.apply_change
        end
    end

  end
end
