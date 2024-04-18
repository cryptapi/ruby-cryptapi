# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module CryptAPI
  class APIError < StandardError
    attr_reader :status_code

    def initialize(message, status_code)
      super(message)
      @status_code = status_code
    end

    def self.from_status_code(status_code, message)
      case status_code
      when 400
        new("Bad Request: #{message}", 400)
      when 401
        new("Unauthorized: #{message}", 401)
      when 403
        new("Forbidden: #{message}", 403)
      when 404
        new("Not Found: #{message}", 404)
      when 500
        new("Internal Server Error", 500)
      else
        new("Unexpected Error: #{message}", status_code)
      end
    end
  end

  class CallbackURLMissing < StandardError; end

  VERSION = "1.0.0.beta"

  CRYPTAPI_URL = 'https://api.cryptapi.io/'
  CRYPTAPI_HOST = 'api.cryptapi.io'

  class API
    def initialize(coin, own_address, callback_url, parameters: {}, ca_params: {})
      raise CryptAPI::CallbackURLMissing, 'Provide your callback URL' if callback_url.nil?

      _cb = URI::parse(callback_url)

      @callback_url = URI::HTTPS.build(
        host: _cb.host,
        path: _cb.path,
        query: URI.encode_www_form(parameters)
      )
      @coin = coin
      @own_address = own_address
      @parameters = parameters
      @ca_params = ca_params
      @payment_address = ''
    end

    def get_address
      return nil if @coin.nil?

      _params = {
        'callback' => @callback_url,
      }.merge(@ca_params)

      if !@own_address.nil? && !@own_address.empty?
        _params['address'] = @own_address
      end

      _address = CryptAPI::process_request_get(@coin, 'create', _params)

      return nil unless _address

      @payment_address = _address['address_in']

      _address
    end

    def get_logs
      _params = {
        'callback' => @callback_url,
      }

      _logs = CryptAPI::process_request_get(@coin, 'logs', _params)

      return nil unless _logs

      p _logs

      _logs
    end

    def get_qrcode(value: nil, size: 300)
      return nil if @coin.nil?

      p size

      address = @payment_address

      address = get_address['address_in'] if address.nil? or address.empty?

      _params = {
        'address' => address,
        'size' => size,
      }

      if value.is_a? Numeric
        _params['value'] = value
      end

      p _params

      _qrcode = CryptAPI::process_request_get(@coin, 'qrcode', _params)

      return nil unless _qrcode

      _qrcode
    end

    def get_conversion(from_coin, value)
      _params = {
        'from' => from_coin,
        'value' => value,
      }

      _conversion = CryptAPI::process_request_get(@coin, 'convert', _params)

      return nil unless _conversion

      _conversion
    end

    def self.get_info(coin: nil, prices: 0)
      _params = {
        'prices' => prices,
      }

      _info = CryptAPI::process_request_get(coin, 'info', _params)

      return nil unless _info

      _info
    end

    def self.get_supported_coins
      _info = get_info

      _info.delete('fee_tiers')

      _coins = {}

      _info.each do |ticker, coin_info|
        if coin_info.key?('coin')
          _coins[ticker] = coin_info['coin']
        else
          coin_info.each do |token, token_info|
            _coins[ticker + '_' + token] = token_info['coin'] + ' (' + ticker.upcase + ')'
          end
        end
      end

      _coins
    end

    def self.get_estimate(coin, addresses: 1, priority: 'default')
      _params = {
        'addresses' => addresses,
        'priority' => priority,
      }

      _estimate = CryptAPI::process_request_get(coin,'estimate', _params)

      return nil unless _estimate

      _estimate
    end
  end

  private

  def self.process_request_get(coin, endpoint, params)
    coin = coin.nil? ? '' : "#{coin.tr('_', '/')}/"

    response = Net::HTTP.get_response(URI.parse("#{CRYPTAPI_URL}#{coin}#{endpoint}/?#{URI.encode_www_form(params)}"))

    response_obj = JSON.parse(response.body)

    if !response.is_a?(Net::HTTPSuccess) || response_obj['status'] == 'error'
      error = APIError.from_status_code(response.code.to_i, response_obj['error'])
      raise error
    end

    response_obj
  end
end
