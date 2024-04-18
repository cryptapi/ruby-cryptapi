[<img src="https://camo.githubusercontent.com/b6f4519654881a8830f49e13a5c277646d4257f6012d8c21b0ad3dffacf8b73f/68747470733a2f2f692e696d6775722e636f6d2f49664d416137452e706e67" width="300"/>](image.png)

# CryptAPI Ruby Library
Ruby implementation of CryptAPI's payment gateway

## Table of Contents
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [API and utils](#api-and-utils)
4. [Help](#help)

## Requirements:

```
Ruby >= 3
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add <gem-name-here>

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install <gem-name-here>

[RubyGem Page](https://rubygems.org/gems/)

## API and utils

### Importing in your project file

```ruby
require 'cryptapi'
```

### Get information (service of regarding a cryptocurrency)

```ruby
require 'cryptapi'

info = CryptAPI::API.get_info(coin, prices)

# or if you wish to get full CryptAPI service information

info = CryptAPI::API.get_info(nil, prices)

```

### Where
* ``coin`` is the coin you wish to use, from CryptAPI's supported currencies (e.g 'btc', 'eth', 'erc20_usdt', ...).
* ``prices`` by default `0`. If `1` will return the prices of the cryptocurrencies converted to all supported FIAT currencies.

### Generating a new Address

```ruby
require 'cryptapi'

coin = 'trc20_usdt'
own_address = 'TGfBcXvtZKxxku4X8yx92y56HdYTATKuDF'
callback_url = 'https://example.com/callback/'

cryptapi_helper = CryptAPI::API.new(coin, own_address, callback_url, parameters: {'order_id'=> 1}, ca_params: {'convert' => 1})

address = cryptapi_helper.get_address

# or address['address_in'] if you just wish the address string
```

#### Where:

* ``coin`` is the coin you wish to use, from CryptAPI's supported currencies (e.g 'btc', 'eth', 'erc20_usdt', ...).
* ``own_address`` is your own crypto address, where your funds will be sent to.
* ``callback_url`` is the URL that will be called upon payment.
* ``parameters`` is any parameter you wish to send to identify the payment, such as `{orderId: 1234}`.
* ``ca_params`` parameters that will be passed to CryptAPI _(check which extra parameters are available here: https://docs.cryptapi.io/#operation/create).

#### Response sample:

```json
{
  "status": "success",
  "address_in": "0xe10818d4037B7C427109dFbCFC2c8757c0352FE8", 
  "address_out": "0xA6B78B56ee062185E405a1DDDD18cE8fcBC4395d", 
  "callback_url": "https://webhook.site/ef8e2859-12a9-4028-8a94-51582e83dd05?order_id=13435", 
  "minimum_transaction_coin": "1.00000000", 
  "priority": "default", 
  "multi_token": true
}
```

### Getting notified when the user pays

> Once your customer makes a payment, CryptAPI will send a callback to your `callbackUrl`. This callback information is by default in ``GET`` but you can se it to ``POST`` by setting ``post => 1`` in ``ca_params``. The parameters sent by CryptAPI in this callback can be consulted here: https://docs.cryptapi.io/#operation/confirmedcallbackget

### Checking the logs of a request

```ruby
require 'cryptapi'

coin = 'trc20_usdt'
own_address = 'TGfBcXvtZKxxku4X8yx92y56HdYTATKuDF'
callback_url = 'https://example.com/callback/'

cryptapi_helper = CryptAPI::API.new(coin, own_address, callback_url, parameters: {'order_id'=> 1}, ca_params: {'convert' => 1})

logs = cryptapi_helper.get_logs
```
> Same parameters as before, the ```data``` returned can b e checked here: https://docs.cryptapi.io/#operation/logs

#### Response sample:

```json
{
  "status": "success",
  "callback_url": "https://example.com/?order_id=1235",
  "address_in": "0x58e90D31530A5566dA97e34205730323873eb88B",
  "address_out": "0xA6B78B56ee062185E405a1DDDD18cE8fcBC4395d",
  "notify_pending": false,
  "notify_confirmations": 1,
  "priority": "default",
  "callbacks": []
}
```

### Generating a QR code

```ruby
require 'cryptapi'

coin = 'trc20_usdt'
own_address = 'TGfBcXvtZKxxku4X8yx92y56HdYTATKuDF'
callback_url = 'https://example.com/callback/'

cryptapi_helper = CryptAPI::API.new(coin, own_address, callback_url, parameters: {'order_id'=> 1}, ca_params: {'convert' => 1})

qrcode = cryptapi_helper.get_qrcode(value: 10, size: 512)
```

#### Where:

* ``value`` is the value requested to the user in the coin to which the request was done. **Optional**, can be empty if you don't wish to add the value to the QR Code.
* ``size`` Size of the QR Code image in pixels. Optional, leave empty to use the default size of 300.

> Response is an object with `qr_code` (base64 encoded image data) and `payment_uri` (the value encoded in the QR), see https://docs.cryptapi.io/#operation/qrcode for more information.

#### Response sample:
```json
{
  "status": "success",
  "qr_code": "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",
  "payment_uri": "0x0E945b1554c8029A6B9bE1F7A24ae75d2F44d8DB"
}
```

#### Usage
```html.erb
<img src={"data:image/png;base64,#{qr_code}"}/>
```

### Estimating transaction fees

```ruby
require 'cryptapi'

estimation = CryptAPI::API.get_estimate(coin, addresses: 1, priority: 'default')
```

#### Where:
* ``coin`` is the coin you wish to check, from CryptAPI's supported currencies (e.g 'btc', 'eth', 'erc20_usdt', ...)
* ``addresses`` The number of addresses to forward the funds to. Optional, defaults to 1.
* ``priority`` Confirmation priority, (check [this](https://support.cryptapi.io/article/how-the-priority-parameter-works) article to learn more about it). Optional, defaults to ``default``.

> Response is an object with ``estimated_cost`` and ``estimated_cost_usd``, see https://docs.cryptapi.io/#operation/estimate for more information.

#### Response sample:

```json
{
  "status": "success",
  "estimated_cost": "0.00637010",
  "estimated_cost_currency": {
    "AED": "0.03",
    "AUD": "0.01",
    "BGN": "0.01",
    "BRL": "0.04"
  }
}
```

### Converting between coins and fiat

```ruby
require 'cryptapi'

coin = 'trc20_usdt'
own_address = 'TGfBcXvtZKxxku4X8yx92y56HdYTATKuDF'
callback_url = 'https://example.com/callback/'

cryptapi_helper = CryptAPI::API.new(coin, own_address, callback_url, parameters: {'order_id'=> 1}, ca_params: {'convert' => 1})

conversion = cryptapi_helper.get_conversion(from_coin, value)
```

#### Where:

* ``value`` value to convert in `from`.
* ``from_coin`` currency to convert from, FIAT or crypto.

> Response is an object with ``value_coin`` and ``exchange_rate``, see https://docs.cryptapi.io/#operation/convert for more information.

#### Response sample:

```json
{ 
  "status": "success", 
  "value_coin": "241.126", 
  "exchange_rate": "0.803753"
}
```

### Getting supported coins

```ruby
require 'cryptapi'

supported_coins = CryptAPI::API.get_supported_coins
```

> Response is an array with all supported coins.

#### Response sample:

```json
{
  "btc": {
    "coin": "Bitcoin",
    "logo": "https://api.cryptapi.io/media/token_logos/btc.png",
    "ticker": "btc",
    "minimum_transaction": 8000,
    "minimum_transaction_coin": "0.00008000",
    "minimum_fee": 546,
    "minimum_fee_coin": "0.00000546",
    "fee_percent": "1.000",
    "network_fee_estimation": "0.00002518"
  },
  "bch": {
    "coin": "Bitcoin Cash",
    "logo": "https://api.cryptapi.io/media/token_logos/bch.png",
    "ticker": "bch",
    "minimum_transaction": 50000,
    "minimum_transaction_coin": "0.00050000",
    "minimum_fee": 546,
    "minimum_fee_coin": "0.00000546",
    "fee_percent": "1.000",
    "network_fee_estimation": "0.00000305"
  }
}
```

## Help

Need help?  
Contact us @ https://cryptapi.io/contacts/
