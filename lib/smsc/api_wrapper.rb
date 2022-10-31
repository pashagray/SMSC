require "json"

module SMSC
  class ApiWrapper
    include Dry::Monads[:result, :do]
    include Dry::Monads[:try]

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
      res = Try(*NETWORK_ERRORS) do
        conn = Faraday.new(url: uri) do |faraday|
          faraday.request :url_encoded
        end
  
        response = conn.post(uri) do |req|
          req.body = {
            login: @login,
            psw: @password,
            fmt: @format,
            charset: @charset
          }
        end
      end

      return Failure(:network_error) if res.error?

      hash = JSON.parse(res.value!.body, symbolize_names: true)
      if hash[:error_code]
        return Failure(REQUEST_ERRORS[hash[:error_code].to_s])
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
