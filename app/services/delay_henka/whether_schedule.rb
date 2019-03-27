require 'pry'
module DelayHenka
  class WhetherSchedule

    def initialize(record)
      @record = record.dup
    end

    def make_decision(attribute, new_val)
      Keka.run do
        old_val = record.public_send(attribute)
        record.public_send("#{attribute}=", new_val)
        # can't use xxx_changed? because #dup gives us a new instance
        Keka.err_if! old_val == record.public_send(attribute)
        Keka.ok_if! record.valid?
        Keka.err_if! true, record.errors.full_messages.join(', ')
      end
    end

    private
    attr_reader :record

  end
end
