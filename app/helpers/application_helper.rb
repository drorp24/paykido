module ApplicationHelper

  # Note: This number_to_currency implementation assumes either global default currency or current_payer.currency
  # For Money class items, that have embedded currency, use Money helper: humanized_money_with_symbol 
  def number_to_currency(number, options = {})
    return unless number
    amount = number.to_d * 100
    currency = current_payer.currency? ? current_payer.currency : Money.default_currency.iso_code
    humanized_money_with_symbol Money.new(amount, currency)
  end

end
