# Immutable value object describing one reservation status change.
class ReservationEvent
  VALID_STATUSES = %w[
    confirmed checked_in checked_out do_not_disturb service_requested
  ].freeze

  attr_reader :status, :location, :timestamp, :notes

  def initialize(status:, location:, timestamp: Time.now, notes: nil)
    unless VALID_STATUSES.include?(status)
      raise ArgumentError, "Invalid reservation status: #{status}"
    end

    @status = status.dup.freeze
    @location = location.dup.freeze
    @timestamp = timestamp.dup.freeze
    @notes = notes.nil? ? nil : notes.dup.freeze
    freeze
  end

  def to_s
    "[#{timestamp.strftime('%Y-%m-%d %H:%M:%S')}] #{status} at #{location}"
  end
end
