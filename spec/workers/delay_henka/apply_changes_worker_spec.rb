require 'rails_helper'

module DelayHenka
  RSpec.describe ApplyChangesWorker do

    describe '#perform' do
      let!(:changeable){ Foo.create(attr_chars: 'hello') }

      it 'create new record' do
        changeable_class = DelayHenka::Foo
        ScheduledChange.create(
          changeable_type: changeable_class.to_s,
          submitted_by_id: 10,
          new_value: {attr_chars: 'hello', attr_int: 10},
          schedule_at: Time.current,
          action_type: ScheduledChange::ACTION_TYPES[:CREATE]
        )

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }
            .to change{ changeable_class.count }.by(1)
          created = changeable_class.last
          expect(created).to have_attributes({
            attr_chars: 'hello',
            attr_int: 10
          })
        end
      end

      it 'updates state of replaced changes' do
        ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'hello', new_value: 'world', schedule_at: Time.current)
        ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_int', old_value: nil, new_value: 5, schedule_at: Time.current)

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }
            .to change{ changeable.reload.attr_chars }.from('hello').to('world')
            .and change{ changeable.reload.attr_int }.from(nil).to(5)
        end
      end

      it 'does not apply replaced changes' do
        change_1 = ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'hello', new_value: 'w1', schedule_at: Time.current)
        change_2 = ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'hello', new_value: 'w2', schedule_at: Time.current)
        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }
            .to change{ changeable.reload.attr_chars }.from('hello').to('w2')
            .and change{ change_1.reload.state }.to(DelayHenka::ScheduledChange::STATES[:REPLACED])
            .and change{ change_2.reload.state }.to(DelayHenka::ScheduledChange::STATES[:COMPLETED])
        end
      end


      it 'not updates until current time >= schedule_at' do
        ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'hello', new_value: 'world', schedule_at: 3.days.from_now)

        Sidekiq::Testing.inline! do
          expect{ described_class.perform_async }
            .to_not change{ changeable.reload.attr_chars }.from('hello')
        end
      end
    end

  end
end
