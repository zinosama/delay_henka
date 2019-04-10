module DelayHenka
  class ApplyActionsWorker

    include Sidekiq::Worker

    def perform
      ScheduledAction.staged
        .where('schedule_at <= ?', Time.current)
        .includes(:actionable)
        .find_each(&:apply_action)
    end

  end
end
