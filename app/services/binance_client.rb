# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"
require "json"

class BinanceClient
  API_BASE = "https://api.binance.com"

  def initialize(http_client: Faraday.new(url: API_BASE))
    @http_client = http_client
  end

  def get_price(symbol)
    response = @http_client.get("/api/v3/ticker/price", { "symbol" => symbol.to_s.upcase })
    return nil unless response.success?

    data = JSON.parse(response.body)
    price_str = data["price"]
    return nil unless price_str

    BigDecimal(price_str)
  rescue StandardError
    nil
  end

  private

  attr_reader :http_client
end
