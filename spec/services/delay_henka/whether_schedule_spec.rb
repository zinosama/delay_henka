require 'rails_helper'

module DelayHenka
  RSpec.describe WhetherSchedule do

    describe '#make_decision' do
      let(:record) { Foo.create(attr_chars: 'hello', attr_int: 10) }
      let(:service) { described_class.new(record) }

      it 'does not change original object' do
        expect{ service.make_decision(:attr_int, 8) }.not_to change{ record.attr_int }.from(10)
        expect{ service.make_decision(:attr_int, 0.5) }.not_to change{ record.attr_int }.from(10)
        expect{ service.make_decision(:attr_int, nil) }.not_to change{ record.attr_int }.from(10)
      end

      it 'returns err keka without msg when there is no change' do
        output = service.make_decision(:attr_int, 10)
        expect(output).not_to be_ok
        expect(output.msg).to be_nil
      end

      it 'returns err keka with object when new val is invalid' do
        output = service.make_decision(:attr_int, 0)

        # doesn't change original record
        expect(record.attr_int).to eq 10

        expect(output).not_to be_ok
        expect(output.msg).to eq 'Attr int must be greater than 1'
      end

      it 'returns ok keka when new val is valid' do
        output = service.make_decision(:attr_int, 8)
        expect(output).to be_ok
      end
    end

  end
end
