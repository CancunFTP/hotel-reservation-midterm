require "spec_helper"

RSpec.describe Reservation do
  let(:room) { SuiteRoom.new(room_number: 204, nights: 3) }
  let(:notifier) { double("notifier", notify: nil) }
  let(:reservation) do
    described_class.new(guest_name: "Carol", room: room, notifiers: [notifier])
  end
  let(:first_time) { Time.local(2025, 6, 15, 14, 0, 0) }
  let(:second_time) { Time.local(2025, 6, 15, 15, 30, 0) }

  describe "#initialize" do
    it "stores the guest's name" do
      expect(reservation.guest_name).to eq("Carol")
    end

    it "generates a confirmation number beginning with RES" do
      expect(reservation.confirmation_number).to match(/\ARES[0-9A-F]+\z/)
    end

    it "generates unique confirmation numbers" do
      another = described_class.new(guest_name: "Lee", room: room, notifiers: [notifier])
      expect(another.confirmation_number).not_to eq(reservation.confirmation_number)
    end

    it "rejects an empty notifier array with the specified error" do
      expect do
        described_class.new(guest_name: "Carol", room: room, notifiers: [])
      end.to raise_error(ArgumentError, "At least one notifier is required")
    end

    it "does not expose the internal room, event list, or notifier list" do
      expect(reservation).not_to respond_to(:room, :events, :notifiers)
    end

    it "copies the injected notifier list so callers cannot change the subscription" do
      listeners = [notifier]
      booking = described_class.new(guest_name: "Carol", room: room, notifiers: listeners)
      listeners.clear
      expect(notifier).to receive(:notify).once
      booking.update_status(status: "confirmed", location: "Front Desk")
    end
  end

  describe "#latest_status and #current_status" do
    it "starts as not_yet_confirmed" do
      expect(reservation.latest_status).to eq("not_yet_confirmed")
      expect(reservation.current_status).to eq("not_yet_confirmed")
    end

    it "returns the most recently recorded status" do
      reservation.update_status(status: "confirmed", location: "Front Desk")
      reservation.update_status(status: "checked_in", location: "Room 204")
      expect(reservation.latest_status).to eq("checked_in")
      expect(reservation.current_status).to eq("checked_in")
    end
  end

  describe "#update_status" do
    it "returns a ReservationEvent with the supplied details" do
      event = reservation.update_status(
        status: "checked_in", location: "Room 204", timestamp: first_time,
        notes: "Late arrival"
      )
      expect(event).to be_a(ReservationEvent)
      expect(event.status).to eq("checked_in")
      expect(event.location).to eq("Room 204")
      expect(event.timestamp).to eq(first_time)
      expect(event.notes).to eq("Late arrival")
    end

    it "stores each new event in insertion/guest-journey order" do
      reservation.update_status(status: "confirmed", location: "Front Desk", timestamp: first_time)
      reservation.update_status(status: "checked_in", location: "Room 204", timestamp: second_time)
      expect(reservation.event_history.map(&:status)).to eq(%w[confirmed checked_in])
      expect(reservation.event_history.map(&:timestamp)).to eq([first_time, second_time])
    end

    it "invokes a notifier with exactly the reservation and new event" do
      expect(notifier).to receive(:notify) do |actual_reservation, event|
        expect(actual_reservation).to equal(reservation)
        expect(event.status).to eq("confirmed")
        expect(reservation.event_history).to include(event)
      end
      reservation.update_status(status: "confirmed", location: "Front Desk")
    end

    it "invokes all injected notifiers in the order provided" do
      seen = []
      first = double("first")
      second = double("second")
      allow(first).to receive(:notify) { |_, event| seen << ["first", event] }
      allow(second).to receive(:notify) { |_, event| seen << ["second", event] }
      booking = described_class.new(guest_name: "Carol", room: room, notifiers: [first, second])
      event = booking.update_status(status: "confirmed", location: "Front Desk")
      expect(seen).to eq([["first", event], ["second", event]])
    end

    it "notifies on every event, not only the first event" do
      expect(notifier).to receive(:notify).twice
      reservation.update_status(status: "confirmed", location: "Front Desk")
      reservation.update_status(status: "service_requested", location: "Room 204")
    end

    it "rejects an invalid status without appending or notifying" do
      expect(notifier).not_to receive(:notify)
      expect do
        reservation.update_status(status: "cancelled", location: "Front Desk")
      end.to raise_error(ArgumentError, /Invalid reservation status/)
      expect(reservation.event_history).to be_empty
    end

    it "allows no notes to be supplied" do
      event = reservation.update_status(status: "confirmed", location: "Front Desk")
      expect(event.notes).to be_nil
    end
  end

  describe "#event_history" do
    it "is initially empty" do
      expect(reservation.event_history).to eq([])
    end

    it "does not allow callers to mutate internal event storage" do
      snapshot = reservation.event_history
      expect { snapshot << "fake event" }.to raise_error(FrozenError)
      expect(reservation.event_history).to eq([])
    end
  end

  describe "#total_cost" do
    it "delegates the calculation to the room" do
      expect(room).to receive(:calculate_cost).and_return(275.0)
      expect(reservation.total_cost).to eq(275.0)
    end

    it "works with a different Room subclass without changing Reservation" do
      cabana = CabanaRoom.new(room_number: 99, nights: 3)
      booking = described_class.new(guest_name: "Alex", room: cabana, notifiers: [notifier])
      expect(booking.total_cost).to eq(300.0)
    end
  end
end
