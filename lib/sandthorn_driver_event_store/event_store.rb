module SandthornDriverEventStore
  class EventStore

    attr_reader :driver

    def initialize event_store_driver:
      @driver = event_store_driver
      driver.execute do |db|
        @storage = db
      end
    end

    def save_events events, aggregate_id, aggregate_type
      driver.execute do |db|
        event_access = get_event_access(db)
        events = events.map { |event| event[:aggregate_type] = aggregate_type; event[:aggregate_id] = aggregate_id; event;}
        event_access.store_events(events)
      end
    end

    def find aggregate_id, aggregate_type, after_aggregate_version = 0
      driver.execute do |db|
        event_access = get_event_access(db)
        event_access.find_events(aggregate_id, aggregate_type, after_aggregate_version)
      end
    end

    def all aggregate_type
      raise :NotImplemented
    end

    def get_events(*args)
      raise :NotImplemented
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