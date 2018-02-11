require "json"

module SMSC
  extend Dry::Monads::Try::Mixin

  class RequestStruct < Dry::Struct
    include Dry::Monads::Result::Mixin

    NETWORK_ERRORS = [Errno::ECONNREFUSED].freeze
    ERRORS = {
      2 => :authorize_error
    }
    API_PATH = "https://smsc.kz/sys/".freeze

    constructor_type :strict_with_defaults

    attribute :fmt,   Types::Fmt.default(3)
    attribute :login, Types::Strict::String
    attribute :psw,   Types::Password

    def call
      uri = URI("#{API_PATH}/#{action}.php")
      res = SMSC::Try(*NETWORK_ERRORS) do
        Net::HTTP.post_form(uri, __attributes__)
      end
      return Failure(:network_error) if res.error?
      json = JSON.parse(res.value!.body, symbolize_names: true)
      if json[:error_code]
        return Failure(ERRORS[json[:error_code]])
      else
        Success(json)
      end
    end
  end
end
