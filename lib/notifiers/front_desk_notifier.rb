# Prints a staff alert to the front desk terminal.
class FrontDeskNotifier
  INSTRUCTIONS = {
    "confirmed" => "New reservation confirmed. Please prepare room assignment.",
    "checked_in" => "Guest has checked in. Notify housekeeping to remove turndown service.",
    "checked_out" => "Guest has checked out. Flag room for housekeeping.",
    "do_not_disturb" => "Do Not Disturb active. Hold all housekeeping visits for this room.",
    "service_requested" => "Guest has requested service. Dispatch nearest available staff member."
  }.freeze

  def notify(reservation, event)
    line = "-" * 40
    puts line
    puts "FRONT DESK ALERT"
    puts line
    puts "Reservation : #{reservation.confirmation_number}"
    puts "Status      : #{event.status}"
    puts "Location    : #{event.location}"
    puts "Time        : #{event.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "Notes       : #{event.notes}" if event.notes && !event.notes.empty?
    puts line
    puts instruction_for(event.status)
    puts line
  end

  private

  def instruction_for(status)
    INSTRUCTIONS.fetch(status)
  end
end
