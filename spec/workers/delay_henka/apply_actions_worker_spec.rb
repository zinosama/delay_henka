require 'rails_helper'

module DelayHenka
  RSpec.describe ApplyActionsWorker do

    describe '#perform' do
      let!(:actionable) { Foo.create(attr_chars: 'hello') }

      it 'updates state of changes' do
        record = ScheduledAction.create(actionable: actionable, submitted_by_id: 10, method_name: 'destroy', arguments: [], schedule_at: Time.current)

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }
            .to change{ Foo.count }.from(1).to(0)
            .and change{ record.reload.state }.from(DelayHenka::ScheduledChange::STATES[:STAGED]).to(DelayHenka::ScheduledChange::STATES[:COMPLETED])
        end
      end

      it 'not updates until current time >= schedule_at' do
        ScheduledAction.create(actionable: actionable, submitted_by_id: 10, method_name: 'destroy', arguments: [], schedule_at: 3.days.from_now)

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }
            .to_not change{ Foo.count }.from(1)
        end
      end
    end

  end
end
