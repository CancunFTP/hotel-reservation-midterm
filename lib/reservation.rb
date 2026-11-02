require "securerandom"
require_relative "reservation_event"

# Coordinates one guest's room, events, and injected notifiers.
class Reservation
  attr_reader :guest_name, :confirmation_number

  def initialize(guest_name:, room:, notifiers:)
    if notifiers.empty?
      raise ArgumentError, "At least one notifier is required"
    end

    @guest_name = guest_name.dup.freeze
    @room = room
    @notifiers = notifiers.dup.freeze
    @events = []
    @confirmation_number = "RES#{Time.now.strftime('%Y%m%d%H%M%S%6N')}#{SecureRandom.hex(3).upcase}"
  end

  def update_status(status:, location:, timestamp: Time.now, notes: nil)
    event = ReservationEvent.new(
      status: status,
      location: location,
      timestamp: timestamp,
      notes: notes
    )

    @events << event
    @notifiers.each { |notifier| notifier.notify(self, event) }
    event
  end

  def latest_status
    @events.empty? ? "not_yet_confirmed" : @events.last.status
  end

  alias current_status latest_status

  def event_history
    @events.dup.freeze
  end

  def total_cost
    @room.calculate_cost
  end
end
