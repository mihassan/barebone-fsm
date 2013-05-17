require_relative 'spec_helper'

describe FSM::FSMState do
  let(:fsm){FSM::FSM.new}
  subject{FSM::FSMState.new(fsm, :state_name)}

  describe "#initialize" do
    context "with parameter :state_name" do
      its(:state){should be(:state_name)}
      its(:state){should_not be(:wrong_name)}
      its(:events){should be_a_kind_of(Hash)}
      its(:events){should be_empty}
    end
  end
  
  describe "#to_s" do
    context "with no events" do
      specify{subject.to_s.should be_eql("state_name: []")}
    end
    context "with one event" do
      before{subject.event(:first_event => :new_state)}
      specify{subject.to_s.should be_eql("state_name: [first_event]")}
    end
    context "with two events" do
      before{subject.event(:first_event => :new_state, :second_event => :new_state)}
      specify{subject.to_s.should be_eql("state_name: [first_event, second_event]")}
    end
  end
  
  describe "#event" do
    context "with an event block" do
      before{subject.event(:an_event){:new_state}}
      its(:events){should_not be_empty}
      its(:events){should include(:an_event)}
      its(:events){should have(1).item}
      context "when the event is triggered" do
        describe "the new state" do
          specify{subject.event(:an_event).should be(:new_state)}
        end
      end
    end
    context "with a Hash map" do
      before{subject.event(:an_event=>:new_state)}
      its(:events){should_not be_empty}
      its(:events){should include(:an_event)}
      its(:events){should have(1).item}
      context "when the event is triggered" do
        describe "the new state" do
          specify{subject.event(:an_event).should be(:new_state)}
        end
      end
    end
    context "when triggered event exists" do
      before{subject.event(:an_event){:new_state}}
      describe "the new state" do
        specify{subject.event(:an_event).should be(:new_state)}
      end
    end
    context "when triggered event does not exist" do
      before{subject.event(:default){:new_state}}
      it "should trigger default event" do
        subject.event(:an_event).should be(:new_state)
      end
    end
    context "when neither triggered event nor default event exists" do
      it "should return nil" do
        subject.event(:an_event).should be_nil
      end
    end
  end

  describe "#build" do
    context "with an event block" do
      before{subject.build{event :an_event do :new_state end }}
      its(:events){should_not be_empty}
      its(:events){should include(:an_event)}
      its(:events){should have(1).item}
      context "when the event is triggered" do
        describe "the new state" do
          specify{subject.event(:an_event).should be(:new_state)}
        end
      end
    end
    context "with a Hash map" do
      before{subject.build{event :an_event=>:new_state}}
      its(:events){should_not be_empty}
      its(:events){should include(:an_event)}
      its(:events){should have(1).item}
      context "when the event is triggered" do
        describe "the new state" do
          specify{subject.event(:an_event).should be(:new_state)}
        end
      end
    end
  end
    
  describe "#run" do
    context "when triggered event exists" do
      before{subject.event(:an_event){:new_state}}
      describe "the new state" do
        specify{subject.run{event :an_event}.should be(:new_state)}
      end
    end
    context "when triggered event does not exist" do
      before{subject.event(:default){:new_state}}
      it "should trigger default event" do
        subject.run{event :an_event}.should be(:new_state)
      end
    end
    context "when neither triggered event nor default event exists" do
      it "should return nil" do
        subject.run{event :an_event}.should be_nil
      end
    end
  end

end