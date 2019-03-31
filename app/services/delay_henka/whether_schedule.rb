module DelayHenka
  class WhetherSchedule

    def initialize(record)
      @record = record
    end

    def make_decision(attribute, new_val)
      evaluate_decision(attribute, new_val).tap do
        @record.restore_attributes
      end
    end

    def evaluate_decision(attribute, new_val)
      Keka.run do
        old_val = record.public_send(attribute)
        record.public_send("#{attribute}=", new_val)
        Keka.err_if! old_val == record.public_send(attribute)
        Keka.ok_if! record.valid?
        Keka.err_if! true, record.errors.full_messages.join(', ')
      end
    end

    private
    attr_reader :record

  end
end
