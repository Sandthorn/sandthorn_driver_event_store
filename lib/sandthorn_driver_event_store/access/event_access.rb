require "sandthorn_driver_event_store/errors"

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
        expected_version = event_store_events.first[:position] ? event_store_events.first[:position]-1 : nil
        begin
          storage.append_to_stream(stream_name, event_store_events, expected_version)  
        rescue HttpEventStore::WrongExpectedEventNumber
          raise Errors::WrongAggregateVersionError
        end
        
      end
    end

    def events_by_stream_id(stream_id)

      begin
        return storage.read_all_events_forward(stream_id).map do |event|
          aggregate_id = event.stream_name.split('-',2).last
          {
            event_data:         build_event_data(event.data),
            aggregate_id:       aggregate_id,
            aggregate_version:  event.position+1,
            event_name:         event.type
          }
        end
      rescue HttpEventStore::StreamNotFound
        raise Errors::NoAggregateError
      end
    end

    def events_by_category(category)
      begin
        category_stream = "$ce-#{category}"
        events = storage.read_all_events_forward(category_stream)
        
        return [] if events.nil?
        return events.group_by(&:stream_name).map do |stream_name, stream_events|
          aggregate_id = stream_name.split('-',2).last
          
          stream_events.map do |event|
            {
              event_data:         build_event_data(event.data),
              aggregate_id:       aggregate_id,
              aggregate_version:  event.id+1,
              event_name:         event.type
            }
          end
        end
      rescue HttpEventStore::StreamNotFound
        []
      end
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
        data: build_data(event[:event_data]),
        metadata: build_metadata(event[:event_metadata]),
        event_id: SecureRandom.uuid,
        id: event[:aggregate_id],
        position: event[:aggregate_version] ? event[:aggregate_version]-1 : nil,
        created_time: timestamp
      }
    end

    def build_data event_data
      hash = {}
      unless event_data[:attribute_deltas].nil?
        event_data[:attribute_deltas].each do |item|   
          hash[item[:attribute_name]] = item[:new_value]
        end
      end
      hash.empty? ? nil : hash
    end

    def build_event_data data
      delta = data ? JSON.parse(data.to_json) : []
      
      attribute_deltas = delta.map do |key, value|
        {attribute_name: key, old_value: nil, new_value: value}
      end

      {:attribute_deltas=>attribute_deltas}
    end

    def build_metadata metadata
      metadata ? JSON.parse(metadata.to_json) : nil
    end
  end
end