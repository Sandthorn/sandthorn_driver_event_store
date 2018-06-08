require 'spec_helper'

module SandthornDriverEventStore
  describe EventAccess do

    before do
      prepare_for_test
    end

    let(:db) { Sequel.connect(event_store_url)}
    let(:aggregate_id) { SecureRandom.uuid }
    let(:aggregate_type) { "Foo"}
    let(:aggregate) do
      aggregate_access.register_aggregate(aggregate_id, aggregate_type)
    end
    let(:storage) { return event_store_driver.execute { |db| return db; } }
    let(:access) { EventAccess.new(storage) }

    let(:events) do
      [
        {
          aggregate_version: 1,
          aggregate_id: aggregate_id,
          aggregate_type: aggregate_type,
          event_name: "new",
          event_data: {test: "new_data"}
        },{
          aggregate_version: 2,
          aggregate_id: aggregate_id,
          aggregate_type: aggregate_type,
          event_name: "foo",
          event_data: {test: "foo_data"}
        }
      ]
    end

    describe "#store_events" do

      it "handles both arrays and single events" do
        access.store_events(events[0])
        events = access.find_events(aggregate_id, aggregate_type)
        expect(events.length).to eq(1)
      end

      context "when the aggregate version of an event is incorrect" do
        it "throws an error" do
          event = { aggregate_version: 100, aggregate_id: aggregate_id, aggregate_type: "Foo", event_name: "new", event_data: "noop" }
          expect { access.store_events([event])}.to raise_error HttpEventStore::WrongExpectedEventNumber
        end
      end
    end

    describe "#find_events" do
      context "when there are events" do
        it "returns correct events" do
          access.store_events(events)

          stored_events = access.find_events(aggregate_id, aggregate_type)
          expect(stored_events.size).to eq(events.size)
          expect(stored_events).to all(respond_to(:merge))
          stored_events.each { |event|
            expect(event[:aggregate_id]).to eql aggregate_id
          }
        end
      end
    end

  end
end
