require "net/http"
require "dry-monads"
require "dry-configurable"

require "smsc/version"
require "smsc/types"
require "smsc/constants"
require "smsc/api_wrapper"
require "smsc/balance"
require "smsc/send"
require "smsc/ping"
require "smsc/status"
require "smsc/callback"

module SMSC
  extend Dry::Configurable

  setting :login
  setting :password
end
