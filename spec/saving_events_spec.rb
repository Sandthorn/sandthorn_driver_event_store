require 'spec_helper'
require 'securerandom'

module SandthornDriverEventStore
	describe EventStore do
		context "when saving a prefectly sane event stream" do
			let(:test_events) do
				e = []
				e << {aggregate_version: 1, event_name: "new", event_args: nil, event_data: "---\n:method_name: new\n:method_args: []\n:attribute_deltas:\n- :attribute_name: :@aggregate_id\n  :old_value: \n  :new_value: 0a74e545-be84-4506-8b0a-73e947856327\n"}
				e << {aggregate_version: 2, event_name: "foo", event_args: ["bar"], event_data: "noop"}
				e << {aggregate_version: 3, event_name: "flubber", event_args: ["bar"] , event_data: "noop"}
			end

      let(:aggregate_id) { SecureRandom.uuid }

      it "should be able to save and retrieve events on the aggregate" do
				event_store.save_events test_events, aggregate_id, String
				events = event_store.find aggregate_id
				expect(events.length).to eql test_events.length
			end

			it "should have correct keys when asking for events" do
				event_store.save_events test_events, aggregate_id, String
				events = event_store.find aggregate_id
				event = events.first
				expect(event[:event_data]).to eql(test_events.first[:event_data])
        expect(event[:event_name]).to eql("new")
        expect(event[:aggregate_id]).to eql aggregate_id
        expect(event[:aggregate_version]).to eql 1
			end
    end
  end
end