# Simulates an SMS notification by writing to the terminal.
class TextNotifier
  MESSAGES = {
    "confirmed" => "Your reservation at Grand Hotel is confirmed. See you soon!",
    "checked_in" => "You're checked in! Enjoy your stay at Grand Hotel.",
    "checked_out" => "Thanks for staying with us. Safe travels!",
    "do_not_disturb" => "Do Not Disturb is active for your room.",
    "service_requested" => "We've received your service request and are on our way."
  }.freeze

  def initialize(phone_number:)
    @phone_number = phone_number
  end

  def notify(_reservation, event)
    puts "[SMS to #{@phone_number}]: #{message_for(event.status)}"
  end

  private

  def message_for(status)
    MESSAGES.fetch(status)
  end
end
