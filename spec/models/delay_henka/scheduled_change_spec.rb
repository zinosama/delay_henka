# == Schema Information
#
# Table name: delay_henka_scheduled_changes
#
#  id              :bigint(8)        not null, primary key
#  changeable_type :string           not null
#  changeable_id   :integer
#  attribute_name  :string
#  submitted_by_id :integer          not null
#  state           :string           not null
#  error_message   :text
#  old_value       :jsonb
#  new_value       :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  schedule_at     :datetime         not null
#  action_type     :string           default("update"), not null
#

require 'rails_helper'

module DelayHenka
  RSpec.describe ScheduledChange, type: :model do

    describe '.validation' do
      it 'validate fail when update but id missing' do
        record = described_class.new(changeable_type: 'DelayHenka::Foo',
                                     attribute_name: 'attr_chars',
                                     old_value: 'hello',
                                     new_value: 'world',
                                     schedule_at: Time.current,
                                     action_type: described_class::ACTION_TYPES[:UPDATE])
        expect(record.valid?).to eq(false)
        expect(record.errors[:changeable_id]).to eq(['can\'t be blank'])
      end

      it 'validate fail when update but attribute_name missing' do
        record = described_class.new(changeable_type: 'DelayHenka::Foo',
                                     changeable_id: 1,
                                     old_value: 'hello',
                                     new_value: 'world',
                                     schedule_at: Time.current,
                                     action_type: described_class::ACTION_TYPES[:UPDATE])
        expect(record.valid?).to eq(false)
        expect(record.errors[:attribute_name]).to eq(['can\'t be blank'])
      end
    end

    describe '.schedule' do
      it 'create record' do
        changes = {attr_chars: 'hello', attr_int: 10}
        changeable = Foo.new(changes)
        expect{
            described_class.schedule(record: changeable, changes: changes, by_id: 10)
          }.to change{ described_class.count }
        created = described_class.last
        expect(created).to have_attributes({
          changeable_type: 'DelayHenka::Foo',
          changeable_id: nil,
          old_value: nil,
          submitted_by_id: 10,
          new_value: changes.stringify_keys,
          action_type: described_class::ACTION_TYPES[:CREATE]
        })
      end

      context 'when value does not change,' do
        it 'type casts new value' do
          changeable = Foo.create(attr_chars: 'hello', attr_int: 10)
          expect{
            described_class.schedule(record: changeable, changes: {attr_chars: 'hello', attr_int: '10 '}, by_id: 10)
          }.not_to change{ described_class.count }
        end

        it 'converts empty string to nil' do
          changeable = Foo.create(attr_chars: 'hello')
          expect{
            described_class.schedule(record: changeable, changes: {attr_chars: 'hello', attr_int: ' '}, by_id: 10)
          }.not_to change{ described_class.count }
        end

        it 'does not create scheduled change' do
          changeable = Foo.create(attr_chars: 'hello')
          expect{
            described_class.schedule(record: changeable, changes: {attr_chars: 'hello', attr_int: nil}, by_id: 10)
          }.not_to change{ described_class.count }
        end
      end

      context 'when value changes,' do
        it 'creates singular scheduled change' do
          changeable = Foo.create(attr_chars: 'hello')
          expect{
            described_class.schedule(record: changeable, changes: {attr_chars: 'world', attr_int: nil}, by_id: 10)
          }.to change{ described_class.count }.by(1)

          created = described_class.last
          expect(created.changeable).to eq(changeable)
          expect(created.submitted_by_id).to eq 10
          expect(created.attribute_name).to eq 'attr_chars'
          expect(created.old_value).to eq 'hello'
          expect(created.new_value).to eq 'world'
          expect(created.action_type).to eq described_class::ACTION_TYPES[:UPDATE]
        end

        it 'creates multiple scheduled changes' do
          changeable = Foo.create(attr_chars: 'hello ')
          expect{
            described_class.schedule(record: changeable, changes: {attr_chars: 'world', attr_int: '12'}, by_id: 10)
          }.to change{ described_class.count }.by(2)

          created = described_class.last(2)
          expect(created).to contain_exactly(
            have_attributes(
              changeable: changeable,
              submitted_by_id: 10,
              attribute_name: 'attr_chars',
              old_value: 'hello ',
              new_value: 'world',
            ),
            have_attributes(
              changeable: changeable,
              submitted_by_id: 10,
              attribute_name: 'attr_int',
              old_value: nil,
              new_value: '12',
            )
          )
        end
      end
    end

    describe '#apply_create' do

      context 'when change is applied successfully,' do
        it 'updates state to success' do
          changes = {attr_chars: 'hello', attr_int: 10}
          record = described_class.create(
            changeable_type: 'DelayHenka::Foo',
            submitted_by_id: 10,
            new_value: changes,
            schedule_at: Time.current
          )
          expect{ record.apply_create }
            .to change{ DelayHenka::Foo.count }.by(1)
            .and change{ record.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:COMPLETED])
        end
      end

      context 'when change failed to apply,' do
        it 'updates state to errored and sets error message' do
          changes = {attr_chars: '', attr_int: 10}
          record = described_class.create(
            changeable_type: 'DelayHenka::Foo',
            submitted_by_id: 10,
            new_value: changes,
            schedule_at: Time.current
          )
          expect{ record.apply_create }
            .to change{ record.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:ERRORED])
            .and change{ record.error_message }.from(nil).to('Attr chars can\'t be blank')
        end
      end


    end

    describe '#apply_change' do
      let!(:changeable) { Foo.create(attr_chars: 'hello') }

      context 'when change is applied successfully,' do
        it 'updates state to success' do
          record = described_class.create(
            changeable: changeable,
            submitted_by_id: 10,
            attribute_name: 'attr_chars',
            old_value: 'hello',
            new_value: 'world',
            schedule_at: Time.current
          )
          expect{ record.apply_change }
            .to change{ changeable.reload.attr_chars }.from('hello').to('world')
            .and change{ record.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:COMPLETED])
        end
      end

      context 'when change failed to apply,' do
        it 'updates state to errored and sets error message' do
          record = described_class.create(
            changeable: changeable,
            submitted_by_id: 10,
            attribute_name: 'attr_chars',
            old_value: 'hello',
            new_value: '',
            schedule_at: Time.current
          )

          expect{ record.apply_change }
            .to change{ record.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:ERRORED])
            .and change{ record.error_message }.from(nil).to('Attr chars can\'t be blank')
          expect(changeable.reload.attr_chars).to eq 'hello'
        end
      end

      context 'when target record has been destroyed,' do
        it 'updates state to errored and sets error message' do
          record = described_class.create(
            changeable_type: Foo.name,
            changeable_id: 321,
            submitted_by_id: 10,
            attribute_name: 'attr_chars',
            old_value: 'hello',
            new_value: '',
            schedule_at: Time.current
          )
          expect{ record.apply_change }
            .to change{ record.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:ERRORED])
            .and change{ record.error_message }.from(nil).to('Target record cannot be found')
        end
      end
    end

    describe '#replace_change' do
      it 'updates state' do
        record = described_class.create(changeable: Foo.create, submitted_by_id: 10, attribute_name: 'attr_chars', schedule_at: Time.current)
        expect{ record.replace_change }.to change{ record.reload.state }
          .from(described_class::STATES[:STAGED])
          .to(described_class::STATES[:REPLACED])
      end
    end

  end
end
