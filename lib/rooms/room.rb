# An abstract hotel room. Concrete subclasses define the price.
class Room
  attr_reader :room_number, :nights

  def initialize(room_number:, nights:)
    @room_number = room_number
    @nights = nights
  end

  def calculate_cost
    raise NotImplementedError, "Subclasses must implement calculate_cost"
  end

  def description
    "#{self.class.name}: #{@nights} nights in Room #{@room_number}"
  end

  def to_s
    description
  end
end
