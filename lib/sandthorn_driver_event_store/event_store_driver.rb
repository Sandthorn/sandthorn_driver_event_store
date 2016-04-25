require 'http_eventstore'

module SandthornDriverEventStore
  class EventStoreDriver

    def initialize url:, port:, page_size:

      @connection = HttpEventstore::Connection.new do |config|
         #default value is '127.0.0.1'
         config.endpoint = url
         #default value is 2113
         config.port = port
         #default value is 20 entries per page
         config.page_size = page_size
      end
    end

    def execute
      yield @connection
    end

  end
end
