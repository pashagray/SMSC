require "json"

module SMSC
  extend Dry::Monads::Try::Mixin

  class ApiWrapper
    include Dry::Monads::Result::Mixin

    NETWORK_ERRORS = [Errno::ECONNREFUSED].freeze
    ERRORS = {
      "1" => :bad_parameters,
      "2" => :wrong_credentials,
      "3" => :insufficient_funds,
      "4" => :too_many_errors,
      "5" => :wrong_date_format,
      "6" => :message_is_prohibited,
      "7" => :wrong_phone_number,
      "8" => :not_able_to_deliver,
      "9" => :frequent_requests
    }
    API_PATH = "https://smsc.kz/sys".freeze

    def initialize(login: SMSC.config.login, password: SMSC.config.password, action:)
      raise ArgumentError, "Login and password must be set" unless login && password
      @login    = Types::Strict::String[login]
      @password = Types::Strict::String[password]
      @action   = Types::Strict::Symbol[action]
      @format   = Types::Fmt[3]
      @charset  = "UTF=8"
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
        Success(fix_floats(transform_response(hash)))
      end
    end

    private

    # Overide if response should be differen
    def transform_response(hash)
      hash
    end

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
        fmt: @format,
        charset: @charset
      }.merge(args)
    end
  end
end
