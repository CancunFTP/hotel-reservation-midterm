require_relative "room"

class CabanaRoom < Room
  BASE_RATE = 80.00
  RATE_PER_NIGHT = 40.00
  PEAK_MULTIPLIER = 1.5

  def calculate_cost
    (BASE_RATE + (nights * RATE_PER_NIGHT)) * PEAK_MULTIPLIER
  end
end
