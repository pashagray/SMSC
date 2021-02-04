module SMSC
  class Status < ApiWrapper
    def initialize(**args)
      super(**args.merge(action: :status))
    end

    def call(
      phone:,
      message_id:
    )
      super(
        phone: Types::Phone[phone],
        id: Types::Coercible::Integer[message_id],
        all: 2
      )
    end

    private

    def transform_response(hash)
      to_be_removed = %i[status_name last_timestamp last_date send_date]
      hash
        .reduce({}) do |acc, elem|
          transform_status(acc, elem)
        end
        .reduce({}) do |acc, elem|
          transform_type(acc, elem)
        end
        .reduce({}) do |acc, elem|
          transform_time(acc, elem)
        end
        .reduce({}) do |acc, elem|
          transform_error(acc, elem)
        end
        .select { |k, v| !to_be_removed.include?(k) }
    end

    def transform_status(acc, elem)
      if elem[0] == :status
        acc[elem[0]] = STATUSES[elem[1].to_s]
      else
        acc[elem[0]] = elem[1]
      end
      acc
    end

    def transform_type(acc, elem)
      if elem[0] == :type
        acc[elem[0]] = MSG_TYPES[elem[1].to_s]
      else
        acc[elem[0]] = elem[1]
      end
      acc      
    end

    def transform_time(acc, elem)
      if elem[0] == :send_timestamp
        acc[elem[0]] = Time.at(elem[1].to_i)
      else
        acc[elem[0]] = elem[1]
      end
      acc
    end

    def transform_error(acc, elem)
      if elem[0] == :err
        acc[elem[0]] = MSG_STATUS_ERRORS[elem[1].to_s]
      else
        acc[elem[0]] = elem[1]
      end
      acc
    end
  end
end
