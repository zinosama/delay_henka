require 'rails_helper'

module DelayHenka
  RSpec.describe ApplyActionsWorker do

    describe '#perform' do
      let!(:actionable) { Foo.create(attr_chars: 'hello') }

      it 'executes action when schedule_at is in the past' do
        ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.ago)
        scheduled_action = ScheduledAction.last

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }
            .to change{ Foo.count }.by(-1)
            .and change{ scheduled_action.reload.state }
              .from(DelayHenka::ScheduledChange::STATES[:STAGED])
              .to(DelayHenka::ScheduledChange::STATES[:COMPLETED])
        end
      end

      it 'does not execute action if schedule_at is in the future' do
        ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.from_now)

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }.to_not change{ Foo.count }.from(1)
        end
      end
    end

  end
end
