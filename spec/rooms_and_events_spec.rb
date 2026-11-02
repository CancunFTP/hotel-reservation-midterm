require "spec_helper"

RSpec.describe "Room prices and reservation events" do
  it "describes a room with its type, night count, and number" do
    expect(SuiteRoom.new(room_number: 204, nights: 3).description)
      .to eq("SuiteRoom: 3 nights in Room 204")
  end

  it "does not let the abstract Room calculate a price" do
    expect { Room.new(room_number: 1, nights: 1).calculate_cost }
      .to raise_error(NotImplementedError)
  end

  it "calculates the standard rate" do
    expect(StandardRoom.new(room_number: 101, nights: 3).calculate_cost).to eq(200.0)
  end

  it "calculates the suite rate including the upgrade fee" do
    expect(SuiteRoom.new(room_number: 204, nights: 3).calculate_cost).to eq(275.0)
  end

  it "calculates the cabana rate with the peak multiplier" do
    expect(CabanaRoom.new(room_number: 301, nights: 3).calculate_cost).to eq(300.0)
  end

  it "supports a one-night booking" do
    expect(StandardRoom.new(room_number: 1, nights: 1).calculate_cost).to eq(120.0)
  end

  it "formats a timestamped event" do
    event = ReservationEvent.new(status: "checked_in", location: "Room 412",
                                 timestamp: Time.local(2025, 6, 15, 14, 0, 0))
    expect(event.to_s).to eq("[2025-06-15 14:00:00] checked_in at Room 412")
  end

  it "supports all five statuses" do
    expect(ReservationEvent::VALID_STATUSES).to eq(
      %w[confirmed checked_in checked_out do_not_disturb service_requested]
    )
  end

  it "is an immutable value object" do
    event = ReservationEvent.new(status: "confirmed", location: "Front Desk")
    expect(event).to be_frozen
    expect(event.status).to be_frozen
    expect(event.location).to be_frozen
    expect(event.timestamp).to be_frozen
    expect(event).not_to respond_to(:status=, :location=, :timestamp=, :notes=)
  end
end
