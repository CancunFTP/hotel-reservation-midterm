require "spec_helper"

RSpec.describe "Notifiers" do
  let(:room) { StandardRoom.new(room_number: 412, nights: 2) }
  let(:reservation) do
    Reservation.new(guest_name: "Carol", room: room, notifiers: [double("other")])
  end
  let(:timestamp) { Time.local(2025, 6, 15, 15, 30, 0) }

  def event(status, notes: nil)
    ReservationEvent.new(status: status, location: "Room 412", timestamp: timestamp, notes: notes)
  end

  it "prints the exact confirmation SMS" do
    expect do
      TextNotifier.new(phone_number: "555-0192").notify(reservation, event("confirmed"))
    end.to output("[SMS to 555-0192]: Your reservation at Grand Hotel is confirmed. See you soon!\n").to_stdout
  end

  it "defines a message for all five text notification statuses" do
    expect(TextNotifier::MESSAGES.keys).to match_array(ReservationEvent::VALID_STATUSES)
  end

  it "formats an email with its subject, body, time, and optional notes" do
    expect do
      EmailNotifier.new(guest_email: "guest@example.com")
        .notify(reservation, event("checked_in", notes: "Late arrival"))
    end.to output(/\[Email to guest@example.com\]:.*Subject: Welcome to Grand Hotel!.*Your room is ready.*Status : checked_in.*Location : Room 412.*Time : 2025-06-15 15:30:00.*Notes : Late arrival.*---/m).to_stdout
  end

  it "inserts the confirmation number into a confirmed email subject" do
    expect do
      EmailNotifier.new(guest_email: "guest@example.com")
        .notify(reservation, event("confirmed"))
    end.to output(/Subject: Reservation Confirmed — #{reservation.confirmation_number}/).to_stdout
  end

  it "omits the Notes line from an email when none is present" do
    expect do
      EmailNotifier.new(guest_email: "guest@example.com")
        .notify(reservation, event("confirmed"))
    end.not_to output(/Notes/).to_stdout
  end

  it "prints front desk instructions for the specified status" do
    expect do
      FrontDeskNotifier.new.notify(reservation, event("checked_out", notes: "Early checkout"))
    end.to output(/FRONT DESK ALERT.*Reservation : #{reservation.confirmation_number}.*Notes       : Early checkout.*Guest has checked out. Flag room for housekeeping./m).to_stdout
  end

  it "omits front desk notes when missing" do
    expect do
      FrontDeskNotifier.new.notify(reservation, event("confirmed"))
    end.not_to output(/Notes/).to_stdout
  end

  it "includes all five statuses in the email and front desk mapping tables" do
    expect(EmailNotifier::MESSAGES.keys).to match_array(ReservationEvent::VALID_STATUSES)
    expect(FrontDeskNotifier::INSTRUCTIONS.keys).to match_array(ReservationEvent::VALID_STATUSES)
  end
end
