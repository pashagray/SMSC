module SMSC
  class Balance < RequestStruct
    attribute :action, Types::Strict::Symbol.default(:balance)
    attribute :cur, Types::Cur.default(1)
  end
end
