# frozen_string_literal: true

class PriceChecker
  def triggered?(alert, current_price)
    return false if current_price.nil?

    case alert.direction.to_sym
    when :up
      current_price >= alert.threshold_price
    when :down
      current_price <= alert.threshold_price
    else
      false
    end
  end
end
