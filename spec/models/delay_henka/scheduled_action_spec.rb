require 'pry'
require 'rails_helper'

module DelayHenka
  RSpec.describe ScheduledAction, type: :model do

    describe 'attribues' do
      let!(:record) { Foo.create(attr_chars: 'hello') }
      let(:action) do
        ScheduledAction.new(
          actionable: record,
          submitted_by_id: 10,
          method_name: 'destroy',
          schedule_at: 1.hour.ago,
        )
      end

      it 'is invalid without a time_zone' do
        expect(action).to_not be_valid
      end

      it 'is valid with a time zone' do
        action.time_zone = "Central Time (US & Canada)"
        expect(action).to be_valid
      end
    end

    describe '.schedule' do
      let!(:record) { Foo.create(attr_chars: 'hello') }
      let(:action) do
        -> do
          described_class.schedule(
            record: record,
            method_name: method_name,
            by_id: 10,
            argument: argument,
            time_zone: "Central Time (US & Canada)"
          )
        end
      end

      context 'when method is not defined,' do
        let(:method_name) { :foo }
        let(:argument) { nil }
        it 'returns error keka' do
          result = action.call
          expect(result).not_to be_ok
          expect(result.msg).to match /undefined method `foo' for class/
        end
      end

      context 'when method has 0 arity but argument is provided' do
        let(:method_name) { :no_arity }
        let(:argument) { 'hello' }
        it 'returns error keka' do
          result = action.call
          expect(result).not_to be_ok
          expect(result.msg).to eq 'wrong arity'
        end
      end

      context 'when method has 1 arity but no argument is provided,' do
        let(:method_name) { :single_arity }
        let(:argument) { nil }
        it 'returns error keka' do
          result = action.call
          expect(result).not_to be_ok
          expect(result.msg).to eq 'wrong arity'
        end
      end

      context 'when arity is correct,' do
        let(:method_name) { :single_arity }
        let(:argument) { ['hello world'] }
        it 'creates scheduled action' do
          result = nil
          expect{ result = action.call }.to change{ described_class.count }.by(1)
          expect(result).to be_ok

          created = described_class.last
          expect(created.schedule_at).to be_present
          expect(created.method_name).to eq 'single_arity'
          expect(created.argument).to eq ['hello world'].to_json
        end
      end
    end

    describe '#apply_action' do
      let!(:actionable) { Foo.create(attr_chars: 'hello') }
      let!(:scheduled_action) do
        described_class.create(
          actionable: actionable,
          submitted_by_id: 10,
          method_name: method_name,
          argument: argument,
          schedule_at: Time.current,
          time_zone: "Central Time (US & Canada)"
        )
      end

      context 'when action is applied successfully,' do
        let(:method_name) { 'destroy' }
        let(:argument) { nil.to_json }
        it 'updates scheduled action' do
          expect{ scheduled_action.apply_action }
            .to change{ Foo.count }.by(-1)
            .and change{ scheduled_action.reload.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:COMPLETED])
          expect(JSON.parse(scheduled_action.return_value)).to eq(actionable.attributes)
        end
      end

      context 'when actionable cannot be found,' do
        let(:method_name) { 'destroy' }
        let(:argument) { nil.to_json }
        it 'updates scheduled action and sets err msg' do
          actionable.destroy!
          expect{ scheduled_action.apply_action }
            .to change{ scheduled_action.reload.state }.from(described_class::STATES[:STAGED]).to(described_class::STATES[:ERRORED])
          expect(scheduled_action.error_message).to eq('Target record cannot be found')
        end
      end

      context 'when action errors,' do
        let(:method_name) { 'err_action' }
        let(:argument) { { some_arg: 'hello' }.to_json }
        it 'updates scheduled action and sets err msg' do
          expect{ scheduled_action.apply_action }.to raise_exception('hello raised an exception')
            .and change{ scheduled_action.reload.state }.to(described_class::STATES[:ERRORED])
            .and change{ scheduled_action.reload.error_message }.to eq('hello raised an exception')
        end
      end
    end

  end
end
