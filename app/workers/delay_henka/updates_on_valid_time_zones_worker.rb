module DelayHenka
  class UpdatesOnValidTimeZonesWorker

    include Sidekiq::Worker
    VALID_HOURS = %w(1 2 3).freeze

    def perform
      (ScheduledAction.staged.distinct.pluck(:time_zone) + ScheduledChange.staged.distinct.pluck(:time_zone)).uniq.each do |time_zone|
        if valid_scheduling_time?(time_zone)
          ApplyActionsWorker.perform_async(time_zone)
          ApplyChangesWorker.perform_async(time_zone)
        end
      end
    end

    private

    def valid_scheduling_time?(time_zone)
      return false unless Time.find_zone(time_zone)
      VALID_HOURS.include? Time.current.in_time_zone(time_zone).hour.to_s
    end
  end
end
