# require 'spec_helper'
# require 'securerandom'

# module SandthornDriverEventStore
# 	describe EventStore do
# 		before(:each) { prepare_for_test }
# 		let(:test_events_a) do
# 			e = []
# 			e << {aggregate_version: 1, event_name: "new", event_data: "---\n:method_name: new\n:method_args: []\n:attribute_deltas:\n- :attribute_name: :@aggregate_id\n  :old_value: \n  :new_value: 0a74e545-be84-4506-8b0a-73e947856327\n"}
# 			e << {aggregate_version: 2, event_name: "foo", event_data: "A2"}
# 			e << {aggregate_version: 3, event_name: "bard", event_data: "A3"}
# 		end
# 		let(:aggregate_id_a) { SecureRandom.uuid }
# 		let(:test_events_b) do
# 			e = []
# 			e << {aggregate_version: 1, event_name: "new", event_data: "B1" }
# 			e << {aggregate_version: 2, event_name: "foo", event_data: "B2"}
# 			e << {aggregate_version: 3, event_name: "bar", event_data: "B3"}
# 		end
# 		let(:aggregate_id_b) { SecureRandom.uuid }
# 		let(:test_events_c) do
# 			e = []
# 			e << {aggregate_version: 1, event_name: "new", event_data: "C1" }
# 		end
# 		let(:test_events_c_2) do
# 			e = []
# 			e << {aggregate_version: 2, event_name: "flubber", event_data: "C2" }
# 		end
# 		let(:aggregate_id_c) { SecureRandom.uuid }
# 		before(:each) do
# 			event_store.save_events test_events_a, aggregate_id_a, SandthornDriverEventStore::EventStore
# 			event_store.save_events test_events_c, aggregate_id_c, String
# 			event_store.save_events test_events_b, aggregate_id_b, SandthornDriverEventStore::EventStore
# 			event_store.save_events test_events_c_2, aggregate_id_c, String
# 		end

# 		let(:event) { event_store.find(aggregate_id_c).first }

# 		it "returns events that can be merged" do
# 			expect(event).to respond_to(:merge)
# 		end

# 		context "when using get_events" do
# 			context "and using take" do
# 				let(:events) {event_store.get_events stream_name: "test", after_sequence_number: nil, take: 2}
# 				it "should find 2 events" do
# 					expect(events.length).to eql 2
# 				end
# 			end
# 			context "and combining args" do
# 				let(:events) do
# 					all = event_store.get_events after_sequence_number: 0
# 					first_seq_number = all[0][:sequence_number]
# 					event_store.get_events after_sequence_number: first_seq_number, take: 100
# 				end
# 				it "should find 7 events" do
# 					expect(events.length).to eql 7
# 				end

# 			end
# 			context "and getting events for SandthornDriverEventStore::EventStore, and String after 0" do
# 				let(:events) {event_store.get_events after_sequence_number: 0, aggregate_types: [SandthornDriverEventStore::EventStore, String]}
# 				it "should find 5 events" do
# 					expect(events.length).to eql 5
# 				end
# 				it "should be in sequence_number order" do
# 					check = 0
# 					events.each { |e| expect(e[:sequence_number]).to be > check; check = e[:sequence_number] }
# 				end
# 				it "should contain only events for aggregate_id_a and aggregate_id_c" do
# 					events.each { |e| expect([aggregate_id_a, aggregate_id_c].include?(e[:aggregate_id])).to be_truthy }
# 				end
# 			end
# 			context "and getting events for SandthornDriverEventStore::EventStore after 0" do
# 				let(:events) {event_store.get_events after_sequence_number: 0, aggregate_types: [SandthornDriverEventStore::EventStore]}
# 				it "should find 3 events" do
# 					expect(events.length).to eql 3
# 				end
# 				it "should be in sequence_number order" do
# 					check = 0
# 					events.each { |e| expect(e[:sequence_number]).to be > check; check = e[:sequence_number] }
# 				end
# 				it "should contain only events for aggregate_id_a" do
# 					events.each { |e| expect(e[:aggregate_id]).to eql aggregate_id_a  }
# 				end
# 			end
# 		end
# 		context "when using :get_new_events_after_event_id_matching_classname to get events" do
# 			context "and getting events for SandthornDriverEventStore::EventStore after 0" do
# 				let(:events) {event_store.get_new_events_after_event_id_matching_classname 0, SandthornDriverEventStore::EventStore}
# 				it "should find 3 events" do
# 					expect(events.length).to eql 3
# 				end
# 				it "should be in sequence_number order" do
# 					check = 0
# 					events.each { |e| expect(e[:sequence_number]).to be > check; check = e[:sequence_number] }
# 				end
# 				it "should contain only events for aggregate_id_a" do
# 					events.each { |e| expect(e[:aggregate_id]).to eql aggregate_id_a  }
# 				end
# 				it "should be able to get events after a sequence number" do
# 					new_from = events[1][:sequence_number]
# 					ev = event_store.get_new_events_after_event_id_matching_classname new_from, SandthornDriverEventStore::EventStore
# 					expect(ev.last[:aggregate_version]).to eql 3
# 					expect(ev.length).to eql 1
# 				end
# 				it "should be able to limit the number of results" do
# 					ev = event_store.get_new_events_after_event_id_matching_classname 0, SandthornDriverEventStore::EventStore, take: 2
# 					expect(ev.length).to eql 2
# 					expect(ev.last[:aggregate_version]).to eql 2
# 				end
# 			end
# 			context "and getting events for String after 0" do
# 				let(:events) {event_store.get_new_events_after_event_id_matching_classname 0, "String"}
# 				it "should find 3 events" do
# 					expect(events.length).to eql 2
# 				end
# 				it "should be in sequence_number order" do
# 					check = 0
# 					events.each { |e| expect(e[:sequence_number]).to be > check; check = e[:sequence_number] }
# 				end
# 				it "should contain only events for aggregate_id_c" do
# 					events.each { |e| expect(e[:aggregate_id]).to eql aggregate_id_c  }
# 				end
# 			end
# 		end

# 	end
# end
