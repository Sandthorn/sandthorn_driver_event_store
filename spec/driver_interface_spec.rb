require 'spec_helper'

module SandthornDriverEventStore
	describe EventStore do
		before(:each) { prepare_for_test }
		context "interface structure" do
			let(:subject) { event_store }
      methods = [
        :save_events,
        :find,
        :all,
        :get_events,
        :driver
      ]

      methods.each do |method|
        it "responds to #{method}" do
          expect(subject).to respond_to(method)
        end
      end

    end
	end
end