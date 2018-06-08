module SandthornDriverEventStore
  class EventAccess < Access::Base
    # = EventAccess
    # Reads and writes events.

    def store_events(events = [])
      events = Utilities.array_wrap(events)
      timestamp = Time.now.utc
      stream_name = events.first[:aggregate_type].to_s + "-" +events.first[:aggregate_id]

      event_store_events = events.map do |event|
        build_event_data(timestamp, event)
      end

      if event_store_events.any?
        expected_version = event_store_events.first[:position] > 0 ? event_store_events.first[:position]-1 : nil
        storage.append_to_stream(stream_name, event_store_events, expected_version)
      end
    end

    def find_events(aggregate_id, class_name)
      stream_name = class_name.to_s + "-" + aggregate_id
      return storage.read_all_events_forward(stream_name).map { |event|
        aggregate_id = event.stream_name.partition('-').last
        {
          event_data:         JSON.parse(event.data.to_json, symbolize_names: true),
          aggregate_id:       aggregate_id,
          aggregate_version:  event.position+1,
          event_name:         event.type
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
        event_type: event[:event_name].to_s,
        data: event[:event_data],
        event_id: SecureRandom.uuid,
        id: event[:aggregate_id],
        position: event[:aggregate_version]-1,
        created_time: timestamp
      }
    end

  end
end