require "dry-types"
require "digest"

module SMSC
  module Types
    include Dry::Types.module
    
    OnOff = Types.Constructor(Types::Bool) do |val|
      if val.is_a?(TrueClass)
        "1"
      elsif val.is_a?(FalseClass)
        "0"
      else
        raise Dry::Types::ConstraintError.new("#{val} eql? true or false", val)
      end
    end

    # Simple strip all non digit values
    Phone = String.constructor( -> (val) { String(val).gsub(/[^0-9]/, "") })

    # Wrap
    Phones = Array.constructor( -> (val) { val.map { |phone| Phone[phone] } })

    # Ensure only JSON format (code: 3)
    Message = Types.Value(3)

    # Ensure only JSON format (code: 3)
    Fmt = Types.Value(3)

    # Ensure currency is always returned (code: 1)
    Cur = Types.Value(1)

    # Ensure password is converted to MD5 hash
    Password = String.constructor( -> (val) { Digest::MD5.hexdigest(val) })
  end
end
