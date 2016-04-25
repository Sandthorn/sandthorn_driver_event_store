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
    def driver_from_url url: nil, context: nil, file_output_options: {}
      EventStore.new url: url, context: context, file_output_options: file_output_options
    end

  end
end

