#!/usr/bin/env ruby
require_relative "../lib/rooms/standard_room"
require_relative "../lib/rooms/suite_room"
require_relative "../lib/rooms/cabana_room"
require_relative "../lib/notifiers/text_notifier"
require_relative "../lib/notifiers/email_notifier"
require_relative "../lib/notifiers/front_desk_notifier"
require_relative "../lib/reservation"

puts "=== Hotel Reservation Management System Demo ==="
puts
puts "Creating room..."
room = SuiteRoom.new(room_number: 204, nights: 3)
puts room.description
puts "Estimated stay cost: $#{format('%.2f', room.calculate_cost)}"
puts
puts "Creating reservation with all notifiers..."
notifiers = [
  TextNotifier.new(phone_number: "555-0192"),
  EmailNotifier.new(guest_email: "carol@example.com"),
  FrontDeskNotifier.new
]
reservation = Reservation.new(guest_name: "Carol", room: room, notifiers: notifiers)
puts "Reservation created: #{reservation.confirmation_number} (Guest: #{reservation.guest_name})"
puts
puts "Tracking guest journey..."

[
  ["confirmed", "Front Desk", Time.local(2025, 6, 15, 14, 0, 0)],
  ["checked_in", "Room 204", Time.local(2025, 6, 15, 15, 30, 0)]
].each do |status, location, timestamp|
  puts
  puts "--- #{status} ---"
  reservation.update_status(status: status, location: location, timestamp: timestamp)
end

puts
puts "Current status: #{reservation.latest_status}"
puts "Total events: #{reservation.event_history.length}"
puts "Final cost: $#{format('%.2f', reservation.total_cost)}"
puts
puts "Demo complete!"
