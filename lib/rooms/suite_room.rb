require_relative "room"

class SuiteRoom < Room
  BASE_RATE = 80.00
  RATE_PER_NIGHT = 40.00
  SUITE_FEE = 75.00

  def calculate_cost
    BASE_RATE + (nights * RATE_PER_NIGHT) + SUITE_FEE
  end
end
