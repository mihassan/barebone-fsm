require '../lib/barebone-fsm'

describe FSM::FSM do
  
  context "with default state" do
    
    before :each do
      @fsm = FSM::FSM.new :default
    end
    
    it "should set the default state" do
      @fsm.build do
        state :start do
        end
      end
      @fsm[].state.should be_eql(:start)
      @fsm.run do
        event :undefined
      end
      @fsm[].state.should be_eql(:default)
    end
  
  end
  
  context "without default state" do
    
    before :each do
      @fsm = FSM::FSM.new
    end
    
    it "should not set the default state" do
      @fsm.build do
        state :start do
        end
      end
      @fsm[].state.should be_eql(:start)
      @fsm.run do
        event :undefined
      end
      @fsm[].state.should be_eql(:start)
    end
    
  end
  
  it "should create states on the fly" do
    @fsm = FSM::FSM.new
    @fsm[:new_state].state.should eq(:new_state)
    @fsm.state(:another_state).state.should eq(:another_state)
  end
  
  it "should set current state to the first accessed state" do
    @fsm = FSM::FSM.new
    @fsm[:new_state].state.should eq(:new_state)
    @fsm.state(:another_state).state.should eq(:another_state)
    @fsm.state().state.should eq(:new_state)
  end
  
end