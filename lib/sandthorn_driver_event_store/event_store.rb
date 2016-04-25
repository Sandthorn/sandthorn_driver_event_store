module SandthornDriverEventStore
  class EventStore

    attr_reader :driver

    def initialize event_store_driver:
      @driver = event_store_driver
      driver.execute do |db|
        @storage = db
      end
    end

    def save_events events, aggregate_id, class_name
      driver.execute do |db|
        event_access = get_event_access(db)
        events = events.map { |event| event[:aggregate_type] = class_name; event[:aggregate_id] = aggregate_id; event;}
        event_access.store_events(events)
      end
    end

    def find aggregate_id
      driver.execute do |db|
        event_access = get_event_access(db)
        event_access.find_events_by_aggregate_id(aggregate_id)
      end
    end

    def all aggregate_type
      raise :NotImplemented
    end

    def get_events(*args)
      driver.execute do |db|
        event_access = get_event_access(db)
        event_access.get_events(*args)
      end
    end

    def get_new_events_after_event_id_matching_classname event_id, class_name, take: 0
      get_events(after_sequence_number: event_id, aggregate_types: Utilities.array_wrap(class_name), take: take)
    end

    private

    def get_event_access(db)
      EventAccess.new(storage(db))
    end

    def storage(db)
      @storage
    end

  end
end