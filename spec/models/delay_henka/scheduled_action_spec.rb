require 'rails_helper'

module DelayHenka
  RSpec.describe ScheduledAction, type: :model do

    describe '#apply_action' do
      let!(:actionable) { Foo.create(attr_chars: 'hello') }

      context 'when action is applied successfully,' do
        it 'destroy success' do
          record = described_class.create(
            actionable: actionable,
            submitted_by_id: 10,
            method_name: 'destroy',
            arguments: []
          )
          expect{ record.apply_action }.to change{ Foo.count }.from(1).to(0)
                      .and change{ record.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:COMPLETED])
        end
      end
    end

  end
end
