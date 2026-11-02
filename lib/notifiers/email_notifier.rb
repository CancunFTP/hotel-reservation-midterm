# Simulates a formatted email; it does not contact an email server.
class EmailNotifier
  MESSAGES = {
    "confirmed" => [nil, "We're pleased to confirm your upcoming reservation."],
    "checked_in" => ["Welcome to Grand Hotel!", "Your room is ready. We hope you enjoy every moment of your stay."],
    "checked_out" => ["Thank you for staying with us", "We hope you had a wonderful stay. Your visit means a lot to us."],
    "do_not_disturb" => ["Do Not Disturb Activated", "Your Do Not Disturb preference has been recorded."],
    "service_requested" => ["Service Request Received", "Thank you for reaching out. Our team will be with you shortly."]
  }.freeze

  def initialize(guest_email:)
    @guest_email = guest_email
  end

  def notify(reservation, event)
    subject, opening = message_for(event.status)
    subject ||= "Reservation Confirmed — #{reservation.confirmation_number}"

    puts "[Email to #{@guest_email}]:"
    puts "Subject: #{subject}"
    puts
    puts opening
    puts
    puts "Status : #{event.status}"
    puts "Location : #{event.location}"
    puts "Time : #{event.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "Notes : #{event.notes}" if event.notes && !event.notes.empty?
    puts "---"
  end

  private

  def message_for(status)
    MESSAGES.fetch(status)
  end
end
