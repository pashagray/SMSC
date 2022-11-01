module SMSC
  STATUSES = {
    "-3" => :not_found,
    "-1" => :in_provider_queue,
    "0"  => :in_operator_queue,
    "1"  => :delivered,
    "2"  => :opened,
    "3"  => :expired,
    "20" => :unable_to_deliver,
    "22" => :wrong_number,
    "23" => :prohibited,
    "24" => :insufficient_funds,
    "25" => :unreachable_number
  }

  MSG_TYPES = {
    "0" => :sms,
    "1" => :flash_sms,
    "2" => :binary_sms,
    "3" => :wap_push,
    "4" => :hlr,
    "5" => :ping,
    "6" => :mms,
    "7" => :phone_call
  }

  NETWORK_ERRORS = [Faraday::ConnectionFailed].freeze
  REQUEST_ERRORS = {
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
  MSG_STATUS_ERRORS = {
    "0"   => :ok,
    "1"   => :sub_not_exist,
    "6"   => :sub_not_available,
    "11"  => :sms_disabled,
    "12"  => :device_or_sim_error,
    "13"  => :sub_blocked,
    "21"  => :sms_not_available,
    "200" => :virtual,
    "220" => :query_is_full,
    "240" => :sub_is_busy,
    "241" => :voice_conversion_error,
    "242" => :answerphone_detected,
    "245" => :status_not_obtained,
    "246" => :timeframe_is_wrong,
    "247" => :daily_limit_reached,
    "248" => :routing_error,
    "249" => :wrong_phone_number,
    "250" => :phone_is_disabled_in_settings,
    "251" => :one_phone_limit_reached,
    "252" => :phone_is_prohibited,
    "253" => :filtered_as_spam,
    "254" => :sender_not_registered,
    "255" => :rejected_by_operator
  }
  API_PATH = "https://smsc.ru/sys".freeze
end