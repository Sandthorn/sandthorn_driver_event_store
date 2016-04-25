require 'http_eventstore'
require 'in_memory_es'

module SandthornDriverEventStore
  class InMemoryEventStoreDriver

    def initialize
      @connection = HttpEventstore::Connection.new { |config| config.client = HttpEventstore::InMemoryEs.new("localhost", 2113, 20) }
    end

    def execute
      yield @connection
    end

  end
end
