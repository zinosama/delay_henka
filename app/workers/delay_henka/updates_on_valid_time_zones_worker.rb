module DelayHenka
  class UpdatesOnValidTimeZonesWorker

    include Sidekiq::Worker

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
    end
  end
end
