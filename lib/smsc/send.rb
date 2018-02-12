module SMSC
  class Send < ApiWrapper
    def initialize(args={})
      super(args.merge(action: :send))
    end

    def call(phone:, message:, translit: true)
      super(
        phones: Types::Phone[phone],
        mes: Types::Strict::String[message],
        translit: Types::OnOff[translit]
      )
    end
  end
end
