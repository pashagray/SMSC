require "json"

module SMSC
  extend Dry::Monads::Try::Mixin

  class ApiWrapper
    include Dry::Monads::Result::Mixin

    NETWORK_ERRORS = [Errno::ECONNREFUSED].freeze
    ERRORS = {
      "1" => :parameters_error,
      "2" => :authorize_error
    }
    API_PATH = "https://smsc.kz/sys".freeze

    def initialize(login:, password:, action:, data_format: 3)
      @login    = Types::Strict::String[login]
      @password = Types::Strict::String[password]
      @action   = Types::Strict::Symbol[action]
      @format   = Types::Fmt[data_format]
    end

    def call(args={})
      uri = URI("#{API_PATH}/#{@action}.php")
      res = SMSC::Try(*NETWORK_ERRORS) do
        Net::HTTP.post_form(uri, build_body(args))
      end
      return Failure(:network_error) if res.error?
      hash = JSON.parse(res.value!.body, symbolize_names: true)
      if hash[:error_code]
        return Failure(ERRORS[hash[:error_code].to_s])
      else
        Success(fix_floats(hash))
      end
    end

    private

    # HOOK
    # API returns float values as string (eg: "0.00")
    # Convert such values to floats (eg: 0.0)
    def fix_floats(hash)
      Hash[hash.map { |k, v| [k, /\A[0-9]+\.[0-9]+\z/.match(v.to_s) ? v.to_f : v] }]
    end

    def build_body(args)
      {
        login: @login,
        psw: @password,
        fmt: @format
      }.merge(args)
    end
  end
end
