require "sandthorn_driver_event_store/version"
require "sandthorn_driver_event_store/utilities"
require "sandthorn_driver_event_store/wrappers"
require "sandthorn_driver_event_store/event_query"
require "sandthorn_driver_event_store/event_store_context"
require "sandthorn_driver_event_store/access"
require "sandthorn_driver_event_store/storage"
require 'sandthorn_driver_event_store/event_store'
require 'sandthorn_driver_event_store/errors'
require 'sandthorn_driver_event_store/migration'
require 'sandthorn_driver_event_store/file_output_wrappers/events'

module SandthornDriverEventStore
  class << self
    def driver_from_url url: nil, context: nil, file_output_options: {}
      EventStore.new url: url, context: context, file_output_options: file_output_options
    end
    def migrate_db url: nil, context: nil
      migrator = Migration.new url: url, context: context
      migrator.migrate!
    end
  end
end

