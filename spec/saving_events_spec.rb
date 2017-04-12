require 'spec_helper'
require 'securerandom'

module SandthornDriverEventStore
    describe EventStore do
        context "when saving a prefectly sane event stream" do
            let(:test_events) do
                e = []
                e << {aggregate_version: 1, event_name: "new", event_args: {:method_name=>"new", :method_args=>[], :attribute_deltas=>[{:attribute_name=>"aggregate_id", :old_value=>nil, :new_value=>"e147e4bb-e98d-4008-ae9a-0bccce314d7b"}]}}
                e << {aggregate_version: 2, event_name: "foo", event_args: {:method_name=>"foo", :method_args=>[], :attribute_deltas=>[{:attribute_name=>"aggregate_id", :old_value=>nil, :new_value=>"e147e4bb-e98d-4008-ae9a-0bccce314d7b"}]}}
                e << {aggregate_version: 3, event_name: "flubber", event_args: {:method_name=>"flubber", :method_args=>["bar"], :attribute_deltas=>[{:attribute_name=>"aggregate_id", :old_value=>nil, :new_value=>"e147e4bb-e98d-4008-ae9a-0bccce314d7b"}]}}
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
                expect(event[:event_args]).to eql(test_events.first[:event_args])
                expect(event[:event_name]).to eql("new")
                expect(event[:aggregate_id]).to eql aggregate_id
                expect(event[:aggregate_version]).to eql 1
            end
        end
    end
end