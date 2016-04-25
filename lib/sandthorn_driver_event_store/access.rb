module SandthornDriverEventStore
  module Access
    class Base
      # = Access::Base
      # Inheriting classes use +storage+ to provide access to a
      # particular database model/table.
      def initialize(storage)
        @storage = storage
      end

      private

      attr_reader :storage
    end
  end
end

require "sandthorn_driver_event_store/access/event_access"
