module DelayHenka
  class ApplyActionsWorker

    include Sidekiq::Worker

    def perform(time_zone)
      ScheduledAction.staged
        .where('schedule_at <= ?', Time.current)
        .where(time_zone: time_zone)
        .includes(:actionable)
        .find_each(&:apply_action)
    end

  end
end
