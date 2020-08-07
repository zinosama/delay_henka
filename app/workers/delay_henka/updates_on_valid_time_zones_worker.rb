module DelayHenka
  class UpdatesOnValidTimeZonesWorker

    include Sidekiq::Worker

    def perform
      ScheduledAction.staged.distinct.pluck(:time_zone) + ScheduledChange.staged.distinct.pluck(:time_zone).each do |time_zone|
        if valid_scheduling_time?(time_zone)
          ApplyActionsWorker.perform_async(time_zone)
          ApplyChangesWorker.perform_async(time_zone)
        end
      end
    end

    private

    def valid_scheduling_time?(time_zone)
      return false unless Time.find_zone(time_zone)
      valid_times = %w(1 2 3)
      valid_times.include? Time.current.in_time_zone(time_zone).hour.to_s
    end
  end
end
