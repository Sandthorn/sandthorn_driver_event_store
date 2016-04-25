require "sandthorn_driver_event_store/version"
require "sandthorn_driver_event_store/utilities"
require "sandthorn_driver_event_store/wrappers"
require "sandthorn_driver_event_store/event_query"
require "sandthorn_driver_event_store/access"
require 'sandthorn_driver_event_store/event_store'
require 'sandthorn_driver_event_store/event_store_driver'
require 'sandthorn_driver_event_store/errors'

module SandthornDriverEventStore
  class << self
    def driver host:, port:, page_size: 20
      driver = SandthornDriverEventStore::EventStoreDriver.new host: host, port: port, page_size: page_size
      return SandthornDriverEventStore::EventStore.new event_store_driver: driver
    end
  end
end

