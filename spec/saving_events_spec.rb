require 'spec_helper'
require 'securerandom'

module SandthornDriverEventStore
	describe EventStore do
		context "when saving a prefectly sane event stream" do
			let(:test_events) do
				e = []
				e << {aggregate_version: 1, aggregate_id: aggregate_id, event_name: "new", event_data: {}}
				e << {aggregate_version: 2, aggregate_id: aggregate_id, event_name: "foo", event_data: {}}
				e << {aggregate_version: 3, aggregate_id: aggregate_id, event_name: "flubber", event_data: {}}
			end

      let(:aggregate_id) { SecureRandom.uuid }

      it "should be able to save and retrieve events on the aggregate" do
				event_store.save_events test_events, aggregate_id, String
				events = event_store.find aggregate_id, String

				expect(events.length).to eql test_events.length
			end

			it "should have correct keys when asking for events" do
				event_store.save_events test_events, aggregate_id, String
				events = event_store.find aggregate_id, String
				event = events.first
				expect(event[:event_data]).to eql(test_events.first[:event_data])
        expect(event[:event_name]).to eql("new")
        expect(event[:aggregate_id]).to eql aggregate_id
        expect(event[:aggregate_version]).to eql 1
			end
    end
  end
end