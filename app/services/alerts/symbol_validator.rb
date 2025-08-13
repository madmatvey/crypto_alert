# frozen_string_literal: true

module Alerts
  class SymbolValidator
    def initialize(client: BinanceClient.new)
      @client = client
    end

    def valid_symbol?(symbol)
      return false if symbol.to_s.strip.empty?
      price = client.get_price(symbol)
      !price.nil?
    rescue StandardError
      false
    end

    private

    attr_reader :client
  end
end
