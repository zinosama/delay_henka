require 'rails_helper'

module DelayHenka
  RSpec.describe ScheduledChange, type: :model do

    describe '.schedule' do
      context 'when decided to schedule,' do
        before do
          service = instance_double(WhetherSchedule)
          allow(WhetherSchedule).to receive(:new).and_return(service)
          allow(service).to receive(:make_decision).with(:attr_chars, 'world').and_return(Keka.ok)
          allow(service).to receive(:make_decision).with(:attr_int, '12').and_return(Keka.ok)
        end

        it 'creates singular scheduled change' do
          changeable = Foo.create(attr_chars: 'hello')
          output = nil
          expect{
            output = described_class.schedule(record: changeable, changes: { attr_chars: 'world' }, by_id: 10)
          }.to change{ described_class.count }.by(1)

          expect(output).to be_ok

          created = described_class.last
          expect(created.changeable).to eq(changeable)
          expect(created.submitted_by_id).to eq 10
          expect(created.attribute_name).to eq 'attr_chars'
          expect(created.old_value).to eq 'hello'
          expect(created.new_value).to eq 'world'
        end

        it 'creates multiple scheduled changes' do
          changeable = Foo.create(attr_chars: 'hello ')
          output = nil
          expect{
            output = described_class.schedule(record: changeable, changes: {attr_chars: 'world', attr_int: '12'}, by_id: 10)
          }.to change{ described_class.count }.by(2)

          expect(output).to be_ok

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

      context 'when there is error,' do
        before do
          service = instance_double(WhetherSchedule)
          allow(WhetherSchedule).to receive(:new).and_return(service)
          allow(service).to receive(:make_decision).with(:attr_chars, nil)
            .and_return(Keka.err(:some_record))
        end

        it 'returns error keka' do
          changeable = Foo.create(attr_chars: 'hello')
          output = nil
          expect{
            output = described_class.schedule(record: changeable, changes: { attr_chars: '' }, by_id: 10)
          }.not_to change{ described_class.count }

          expect(output).not_to be_ok
          expect(output.msg).to be :some_record
        end
      end

      context 'when there is no error nor change,' do
        before do
          service = instance_double(WhetherSchedule)
          allow(WhetherSchedule).to receive(:new).and_return(service)
          allow(service).to receive(:make_decision).with(:attr_chars, nil).and_return(Keka.err)
        end

        it 'returns ok keka' do
          changeable = Foo.create(attr_chars: 'hello')
          output = nil
          expect{
            output = described_class.schedule(record: changeable, changes: { attr_chars: '' }, by_id: 10)
          }.not_to change{ described_class.count }

          expect(output).to be_ok
          expect(output.msg).to be_nil
        end
      end
    end

    context '.cleanup_val' do
      it { expect(described_class.cleanup_val(' foo ')).to eq 'foo' }
      it { expect(described_class.cleanup_val([:foo])).to eq [:foo] }
      it { expect(described_class.cleanup_val('')).to be_nil }
      it { expect(described_class.cleanup_val(nil)).to be_nil }
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
            new_value: 'world'
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
            new_value: ''
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
            new_value: ''
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
