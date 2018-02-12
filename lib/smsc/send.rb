module SMSC
  class Send < ApiWrapper
    def initialize(args={})
      super(args.merge(action: :send))
    end

    def call(
      phone:,
      message:,
      translit: true,
      tinyurl: false,
      flash: false
    )
      super(
        phones: Types::Phone[phone],
        mes: Types::Strict::String[message],
        translit: Types::OnOff[translit],
        tinyurl: Types::OnOff[tinyurl],
        flash: Types::OnOff[flash]
      )
    end
  end
end
