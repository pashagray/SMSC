module SMSC
  class Balance < ApiWrapper
    def initialize(**args)
      super(**args.merge(action: :balance))
    end

    def call(show_currency: 1)
      super(
        cur: Types::Cur[show_currency]
      )
    end
  end
end
