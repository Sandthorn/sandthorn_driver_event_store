require 'spec_helper'

module SandthornDriverEventStore
  describe EventAccess do

    before do
      prepare_for_test
    end

    let(:db) { Sequel.connect(event_store_url)}
    let(:aggregate_id) { SecureRandom.uuid }
    let(:aggregate) do
      aggregate_access.register_aggregate(aggregate_id, "foo")
    end
    let(:storage) { return event_store_driver.execute { |db| return db; } }
    let(:access) { EventAccess.new(storage) }

    let(:events) do
      [
        {
          aggregate_version: 1,
          aggregate_id: aggregate_id,
          aggregate_type: "Foo",
          event_name: "new",
          event_data: {test: "new_data"},
          event_meta_data: {test: "new_meta_data"},
        },{
          aggregate_version: 2,
          aggregate_id: aggregate_id,
          aggregate_type: "Foo",
          event_name: "foo",
          event_data: {test: "foo_data"},
          event_meta_data: {test: "new_meta_data"},
        }
      ]
    end

    describe "#store_events" do

      it "handles both arrays and single events" do
        access.store_events(events[0])
        events = access.events_by_stream_id("Foo-#{aggregate_id}")
        expect(events.length).to eq(1)
      end

      context "when the aggregate version of an event is incorrect" do
        it "throws an error" do
          event = { aggregate_version: 100, aggregate_id: aggregate_id, aggregate_type: "Foo", event_name: "new", event_data: {test: "noop"} }
          expect { access.store_events([event]) }.to raise_error(Errors::WrongAggregateVersionError)
        end
      end
    end

    describe "#events_by_stream_id" do
      context "when there are events" do
        it "returns correct events" do
          access.store_events(events)

          stored_events = access.events_by_stream_id("Foo-#{aggregate_id}")
          expect(stored_events.size).to eq(events.size)
          expect(stored_events).to all(respond_to(:merge))
          stored_events.each { |event|
            expect(event[:aggregate_id]).to eql aggregate_id
          }
        end
      end

      context "when try to find none existing event on aggregate" do
        it "should return NoAggregateError expection" do  
          expect { access.events_by_stream_id("Foo-123") }.to raise_error(Errors::NoAggregateError)
        end
      end
    end

    describe "#events_by_category" do

      let(:aggregate_id_1) { SecureRandom.uuid }
      let(:aggregate_id_2) { SecureRandom.uuid }
      let(:aggregate_id_3) { SecureRandom.uuid }
      let(:random_category_1) { (0...8).map { (65 + rand(26)).chr }.join }
      let(:random_category_2) { (0...8).map { (65 + rand(26)).chr }.join }



      let(:events_1) do
        [
          {
            aggregate_version: 1,
            aggregate_id: aggregate_id_1,
            aggregate_type: random_category_1,
            event_name: "new",
            event_data: {test: "new_data"}
          },{
            aggregate_version: 2,
            aggregate_id: aggregate_id_1,
            aggregate_type: random_category_1,
            event_name: "foo",
            event_data: {test: "foo_data"}
          }
        ]
      end
      let(:events_2) do
        [
          {
            aggregate_version: 1,
            aggregate_id: aggregate_id_2,
            aggregate_type: random_category_1,
            event_name: "foo",
            event_data: {test: "foo_data"}
          }
        ]
      end
      let(:events_3) do
        [
          {
            aggregate_version: 1,
            aggregate_id: aggregate_id_3,
            aggregate_type: random_category_2,
            event_name: "bar",
            event_data: {test: "bar_data"}
          }
        ]
      end

      context "when there are events" do
        it "returns correct events" do
          access.store_events(events_1)
          access.store_events(events_2)
          access.store_events(events_3)

          #Make sure the category projection is run
          sleep 1
          
          stored_events_by_aggregate = access.events_by_category(random_category_1)
          
          expect(stored_events_by_aggregate.size).to eq(2)
          expect(stored_events_by_aggregate.first.first[:aggregate_id]).to eql aggregate_id_1
          expect(stored_events_by_aggregate.last.first[:aggregate_id]).to eql aggregate_id_2
          
          #Aggregate version
          expect(stored_events_by_aggregate.first.first[:aggregate_version]).to eql 1
          expect(stored_events_by_aggregate.first.last[:aggregate_version]).to eql 2
          expect(stored_events_by_aggregate.last.first[:aggregate_version]).to eql 1
        end
      end

      context "when try to find none existing categories" do
        it "should return NoAggregateError expection" do  
          expect(access.events_by_category(random_category_1).any?).to be_falsy
        end
      end
    end

  end
end
