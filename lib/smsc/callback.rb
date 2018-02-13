require "digest/sha1"

module SMSC
  class Callback
    def call(params, &block)
      if block_given?
        block.call(transform_response(params))
      else
        transform_response(params)
      end
    end

    private

    def transform_response(hash)
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