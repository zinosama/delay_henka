require 'rails_helper'

module DelayHenka
  RSpec.describe ApplyChangesWorker do

    describe '#perform' do
      let!(:changeable){ Foo.create(attr_chars: 'hello') }
      let(:time_zone) { "Central Time (US & Canada)" }

      it 'updates state of replaced changes' do
        ScheduledChange.create(changeable: changeable, submitted_by_email: 'tester@chowbus.com', attribute_name: 'attr_chars', old_value: 'hello', new_value: 'world', schedule_at: Time.current, time_zone: time_zone)
        ScheduledChange.create(changeable: changeable, submitted_by_email: 'tester@chowbus.com', attribute_name: 'attr_int', old_value: nil, new_value: 5, schedule_at: Time.current, time_zone: time_zone)

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async(time_zone) }
            .to change{ changeable.reload.attr_chars }.from('hello').to('world')
            .and change{ changeable.reload.attr_int }.from(nil).to(5)
        end
      end

      it 'does not apply changes outside of a given time zone' do
        ScheduledChange.create(changeable: changeable, submitted_by_email: 'tester@chowbus.com', attribute_name: 'attr_chars', old_value: 'hello', new_value: 'world', schedule_at: Time.current, time_zone: "Eastern Time (US & Canada)")

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async(time_zone) }
            .to_not change{ changeable.reload.attr_chars }.from('hello')
        end
      end

      it 'does not apply replaced changes' do
        change_1 = ScheduledChange.create(changeable: changeable, submitted_by_email: 'tester@chowbus.com', attribute_name: 'attr_chars', old_value: 'hello', new_value: 'w1', schedule_at: Time.current, time_zone: time_zone)
        change_2 = ScheduledChange.create(changeable: changeable, submitted_by_email: 'tester@chowbus.com', attribute_name: 'attr_chars', old_value: 'hello', new_value: 'w2', schedule_at: Time.current, time_zone: time_zone)
        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async(time_zone) }
            .to change{ changeable.reload.attr_chars }.from('hello').to('w2')
            .and change{ change_1.reload.state }.to(DelayHenka::ScheduledChange::STATES[:REPLACED])
            .and change{ change_2.reload.state }.to(DelayHenka::ScheduledChange::STATES[:COMPLETED])
        end
      end


      it 'not updates until current time >= schedule_at' do
        ScheduledChange.create(changeable: changeable, submitted_by_email: 'tester@chowbus.com', attribute_name: 'attr_chars', old_value: 'hello', new_value: 'world', schedule_at: 3.days.from_now, time_zone: time_zone)

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async(time_zone) }
            .to_not change{ changeable.reload.attr_chars }.from('hello')
        end
      end
    end

  end
end
