# frozen_string_literal: true

class PriceChecker
  def triggered?(alert, current_price)
    return false if current_price.nil?

    # Do not trigger on first observation; require a previous price
    return false if alert.last_price.nil?

    case alert.direction.to_sym
    when :up
      alert.last_price < alert.threshold_price && current_price >= alert.threshold_price
    when :down
      alert.last_price > alert.threshold_price && current_price <= alert.threshold_price
    else
      false
    end
  end
end
