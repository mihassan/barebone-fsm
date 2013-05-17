require_relative 'spec_helper'

describe FSM::FSM do
  subject{FSM::FSM.new()}

  describe "#initialize" do
    context "with default state" do
      subject{FSM::FSM.new(:default)}
      its(:states){should have(1).item}
    end
    context "without default state" do
      its(:states){should be_empty}
    end
  end
  
  describe "#to_s" do
    context "with default state" do
      subject{FSM::FSM.new(:default)}
      specify{subject.to_s.should be_eql("FSM: {default: []}")}
    end
    context "without default state" do
      specify{subject.to_s.should be_eql("FSM: {}")}
    end
    context "with one state" do
      before{subject.state(:first_state)}
      specify{subject.to_s.should be_eql("FSM: {>first_state: []}")}
    end
    context "with two states" do
      before{subject.state(:first_state)}
      before{subject.state(:second_state)}
      specify{subject.to_s.should be_eql("FSM: {>first_state: [], second_state: []}")}
    end
    context "with states and events" do
      before{subject.state(:first_state){event :first_event => :second_state}}
      before{subject.state(:second_state){event :second_event => :first_state}}
      specify{subject.to_s.should be_eql("FSM: {>first_state: [first_event], second_state: [second_event]}")}
    end
  end
  
  describe "#state" do
    context "with a state block" do
      before{subject.state(:first_state){event :first_event => :second_state}}
      before{subject.state(:second_state){event :second_event => :first_state}}
      its(:states){should_not be_empty}
      its(:states){should have(2).items}
      describe "state" do
        specify{subject.state.state.should be(:first_state)}
      end
    end
    context "without a state block" do
      before{subject.state(:first_state)}
      its(:states){should_not be_empty}
      its(:states){should have(1).items}
      describe "state" do
        specify{subject.state.state.should be(:first_state)}
      end
    end
    context "without any states" do
      its(:states){should be_empty}
      its(:state){should be_nil}
    end    
    context "with some states" do
      before{subject.state(:first_state)}
      its(:states){should_not be_empty}
      its(:states){should have(1).items}
      its(:state){should_not be_nil}
    end    
  end

  describe "#event" do
    before{subject.state(:first_state){event :first_event => :second_state}}
    before{subject.state(:second_state){event :second_event => :first_state}}
      before{subject.event :first_event}
    describe "state" do
      specify{subject.state.state.should be(:second_state)}
    end
  end

  describe "#build" do
    before{subject.build{state :a_state do event :an_event do :new_state end end}}
    its(:states){should_not be_empty}
    its(:states){should have(1).items}
    its(:state){should_not be_nil}
    describe "state" do
      specify{subject.state.state.should be(:a_state)}
    end
  end
    
  describe "#run" do
    subject{FSM::FSM.new(:default)}
    before{subject.state(:first_state){event :first_event => :second_state}}
    before{subject.state(:second_state){event :second_event => :first_state}}

    context "when triggered event exists" do
      before{subject.run{event :first_event}}
      describe "state" do
        specify{subject.state.state.should be(:second_state)}
      end
    end
    context "when triggered event does not exist" do
      before{subject.run{event :unknown_event}}
      describe "state" do
        specify{subject.state.state.should be(:default)}
      end
    end
    context "when neither triggered event nor default state exists" do
      describe "state" do
        specify{subject.state.state.should be(:first_state)}
      end
    end
  end

end