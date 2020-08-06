require 'rails_helper'

module DelayHenka
  RSpec.describe ApplyActionsWorker do

    describe '#perform' do
      let!(:actionable) { Foo.create(attr_chars: 'hello') }
      let(:time_zone) { "Central Time (US & Canada)" }

      it 'executes action when schedule_at is in the past' do
        ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.ago, time_zone: time_zone)
        scheduled_action = ScheduledAction.last

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async(time_zone) }
            .to change{ Foo.count }.by(-1)
            .and change{ scheduled_action.reload.state }
              .from(DelayHenka::ScheduledChange::STATES[:STAGED])
              .to(DelayHenka::ScheduledChange::STATES[:COMPLETED])
        end
      end

      it 'does not execute action outside of a given time zone' do
        ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.ago, time_zone: "Eastern Time (US & Canada)")
        scheduled_action = ScheduledAction.last

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async(time_zone) }.to_not change{ Foo.count }.from(1)
          expect(scheduled_action.reload.state).to eq DelayHenka::ScheduledChange::STATES[:STAGED]
        end
      end

      it 'does not execute action if schedule_at is in the future' do
        ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.from_now, time_zone: time_zone)
        scheduled_action = ScheduledAction.last

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async(time_zone) }.to_not change{ Foo.count }.from(1)
          expect(scheduled_action.reload.state).to eq DelayHenka::ScheduledChange::STATES[:STAGED]
        end
      end
    end

  end
end
