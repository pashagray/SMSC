module SMSC
  class Ping < ApiWrapper
    def initialize(**args)
      super(**args.merge(action: :send))
    end

    def call(
      phone:
    )
      super(
        phones: Types::Phone[phone],
        ping: true,
        cost: "3"
      )
    end
  end
end
