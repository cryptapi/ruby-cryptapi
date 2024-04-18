# frozen_string_literal: true

require "test_helper"

class TestCryptAPI < Minitest::Test
  COIN = 'bep20_usdt'
  OWN_ADDRESS = '0xA6B78B56ee062185E405a1DDDD18cE8fcBC4395d'
  CALLBACK_URL = 'https://webhook.site/132335a5-6063-430f-949c-032402849a11'
  PARAMETERS =  {
    'order_id': 13435
  }
  CA_PARAMETERS =  {
    'convert': 1,
    'multi_token': 1
  }

  # Tested 16/04/2024 -> All tests OK.

  def test_that_it_has_a_version_number
    refute_nil ::CryptAPI::VERSION
  end

  def test_can_generate_address
    cryptapi_helper = CryptAPI::API.new(COIN, OWN_ADDRESS, CALLBACK_URL, parameters: PARAMETERS, ca_params: CA_PARAMETERS)

    address = cryptapi_helper.get_address
    p address
    refute_nil address['address_in']
  end

  def test_can_fetch_logs
    cryptapi_helper = CryptAPI::API.new(COIN, OWN_ADDRESS, CALLBACK_URL, parameters: PARAMETERS, ca_params: CA_PARAMETERS)

    logs = cryptapi_helper.get_logs

    refute_nil logs
  end

  def test_can_get_qrcode
    cryptapi_helper = CryptAPI::API.new(COIN, OWN_ADDRESS, CALLBACK_URL, parameters: PARAMETERS, ca_params: CA_PARAMETERS)

    qrcode = cryptapi_helper.get_qrcode(value: 10, size: 300)
    # p qrcode
    refute_nil qrcode
  end

  def test_can_get_conversion
    cryptapi_helper = CryptAPI::API.new(COIN, OWN_ADDRESS, CALLBACK_URL, parameters: PARAMETERS, ca_params: CA_PARAMETERS)

    conversion = cryptapi_helper.get_conversion('btc', 10)
    # p conversion
    refute_nil conversion
  end

  def test_can_get_info
    # Coin
    info_c = CryptAPI::API.get_info(coin: 'btc', prices: 1)
    p info_c

    # Full Service Info
    info_s = CryptAPI::API.get_info(prices: 1)
    p info_s

    refute_nil info_c
    refute_nil info_s
  end

  def test_can_get_supported_coins
    supported_coins = CryptAPI::API.get_supported_coins
    # p supported_coins
    refute_nil supported_coins
  end

  def test_can_get_estimate
    estimate = CryptAPI::API.get_estimate('btc')
    # p estimate
    refute_nil estimate
  end
end