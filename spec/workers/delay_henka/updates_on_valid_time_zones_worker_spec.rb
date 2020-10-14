require 'rails_helper'

module DelayHenka
  RSpec.describe UpdatesOnValidTimeZonesWorker do
    let(:time_zone) { "Central Time (US & Canada)" }

    describe '#perform' do
      let!(:actionable) { Foo.create(attr_chars: 'hello') }
      let!(:changeable){ Foo.create(attr_chars: 'goodbye') }

      context 'it does not execute workers' do
        it 'when scheduling time is invalid' do
          travel_to Time.local(2020,8,6,12,0,0) do
            ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.ago, time_zone: time_zone)
            ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'goodbye', new_value: 'adieu', schedule_at: Time.current, time_zone: time_zone)

            Sidekiq::Testing.inline! do
              expect{ described_class.perform_async }
                .to_not change{ Foo.count }.from(2)

              expect(changeable.reload.attr_chars).to eq('goodbye')
            end
          end
        end

        it 'when scheduling time zone is empty' do
          travel_to Time.local(2020,8,6,2,0,0) do
            ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.ago, time_zone: time_zone)
            ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'goodbye', new_value: 'adieu', schedule_at: Time.current, time_zone: " ")

            Sidekiq::Testing.inline! do
              expect{ described_class.perform_async }
                .to_not change{ Foo.count }.from(2)

              expect(changeable.reload.attr_chars).to eq('goodbye')
            end
          end
        end

        it 'when scheduling time zone is incorrect' do
          travel_to Time.local(2020,8,6,2,0,0) do
            ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.ago, time_zone: time_zone)
            ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'goodbye', new_value: 'adieu', schedule_at: Time.current, time_zone: "some time zone")

            Sidekiq::Testing.inline! do
              expect{ described_class.perform_async }
                .to_not change{ Foo.count }.from(2)

              expect(changeable.reload.attr_chars).to eq('goodbye')
            end
          end
        end
      end

      it 'executes workers when scheduling time is valid' do
        travel_to Time.local(2020,8,6,2,0,0) do
          ScheduledAction.schedule(record: actionable, by_id: 10, method_name: 'destroy', schedule_at: 1.hour.ago, time_zone: time_zone)
          ScheduledChange.create(changeable: changeable, submitted_by_id: 10, attribute_name: 'attr_chars', old_value: 'goodbye', new_value: 'adieu', schedule_at: Time.current, time_zone: time_zone)

          Sidekiq::Testing.inline! do
            expect{ described_class.perform_async }
              .to change{ Foo.count }.from(2)
              .and change{ changeable.reload.attr_chars }.from('goodbye').to('adieu')
          end
        end
      end
    end

  end
end
