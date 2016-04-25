module SandthornDriverEventStore
  class EventAccess < Access::Base
    # = EventAccess
    # Reads and writes events.

    def store_events(events = [])
      events = Utilities.array_wrap(events)
      timestamp = Time.now.utc
      stream_name = events.first[:aggregate_id]

      event_store_events = events.map do |event|
        build_event_data(timestamp, event)
      end

      if event_store_events.any?
        expected_version = event_store_events.first[:position] > 0 ? event_store_events.first[:position]-1 : nil
        storage.append_to_stream(stream_name, event_store_events, expected_version)
      end
    end

    def find_events_by_aggregate_id(aggregate_id)
      return storage.read_all_events_forward(aggregate_id).map { |event|
        {
          event_data:         event.data["event_data"],
          aggregate_id:       event.data["aggregate_id"],
          aggregate_version:  event.data["aggregate_version"],
          event_name:         event.data["event_name"]
        }
      }
    end

    def get_events(*args)
      query_builder = EventQuery.new(storage)
      query_builder.build(*args)
      wrap(query_builder.events)
    end

    private

    def wrap(arg)
      events = Utilities.array_wrap(arg)
      events.map { |e| EventWrapper.new(e.values) }
    end

    def build_event_data(timestamp, event)
      {
        event_type: event[:aggregate_type].to_s,
        data: event,
        event_id: SecureRandom.uuid,
        id: event[:aggregate_id],
        position: event[:aggregate_version]-1,
        created_time: timestamp
      }
    end

  end
end