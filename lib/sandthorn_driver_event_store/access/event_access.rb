module SandthornDriverEventStore
  class EventAccess < Access::Base
    # = EventAccess
    # Reads and writes events.

    def store_events(events = [])
      events = Utilities.array_wrap(events)
      timestamp = Time.now.utc
      stream_name = "#{events.first[:aggregate_type]}-#{events.first[:aggregate_id]}"

      event_store_events = events.map do |event|
        build_event(timestamp, event)
      end

      if event_store_events.any?
        expected_version = event_store_events.first[:position] > 0 ? event_store_events.first[:position]-1 : nil
        storage.append_to_stream(stream_name, event_store_events, expected_version)
      end
    end

    def events_by_stream_id(stream_id)
      return storage.read_all_events_forward(stream_id).map { |event|
        event_args = build_event_args event.data, event.type
        aggregate_id = event.stream_name.split('-',2).last

        {
          event_args:         event_args,
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

    def build_event(timestamp, event)
      {
        event_type: event[:event_name].to_s,
        data: build_event_data(event[:event_args]),
        event_id: SecureRandom.uuid,
        id: event[:aggregate_id],
        position: event[:aggregate_version]-1,
        created_time: timestamp
      }
    end

    def build_event_data event_args
      hash = {}
      unless event_args[:attribute_deltas].nil?
        event_args[:attribute_deltas].each do |item|   
          hash[item[:attribute_name]] = item[:new_value]
        end
      end
      hash.empty? ? nil : hash
    end

    def build_event_args data, method_name
      delta = data ? JSON.parse(data.to_json) : []
      
      attribute_deltas = delta.map do |key, value|
        {attribute_name: key, old_value: nil, new_value: value}
      end

      {:method_name=>method_name, :method_args=>[], :attribute_deltas=>attribute_deltas}
    end
  end
end