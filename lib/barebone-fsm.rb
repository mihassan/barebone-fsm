##
# This module implements a basic finite-state machine (FSM).
# An FSM consists of a finite number of states,
# with one of them being the current state of the FSM.
# Transitions are defined between states, which are triggered on events.
# For details on FSM, see this wiki page: {FSM}[http://en.wikipedia.org/wiki/Finite-state_machine].
#
# The motivation behind the module was to implement a very basic barebone FSM in Ruby.
# Features are kept at minimum as well as the code.
# Only two classes for the FSM are defined as the following:
# * FSM -> the finite state machine class
# * FSMState -> the state class
# 
# For further details see the README file.
#
# Author:: Md. Imrul Hassan (mailto:mihassan@gmail.com)
# Copyright:: Copyright: Md. Imrul Hassan, 2013
#
module FSM

  # FSMState class represents a state of the finite state machine.
  # 
  # == Usage
  #   state = FSMState.new :state_name
  #   state.event(:event_name) do # creates the event when block is given
  #     puts "#{@event} triggered on state #{@state}"
  #     :new_state
  #   end  
  #   puts state
  #   state.event :event_name # triggers the event when block is absent
  #
  class FSMState

    # The readonly state variable represents an unique state.
    # Though it can have any data type, usage of symbol or string is preferable.
    attr_reader :state

    def initialize(state_machine, state_name) 
      @fsm = state_machine
      @state = state_name
      @events = {}
    end

    def to_s() 
      @state.to_s + 
        ": [" + 
          @events.keys.map(&:to_s).join(', ') + 
        "]" 
    end

    # When the event_block is provided, it sets up a new event for this state.
    # Otherwise, when the event_block is missing, the event_name is triggered.
    # If the event is nil or not already setup, then the default event is triggered.
    def event(event_name, &event_block)
      if event_name and block_given? then
        @events[event_name] = event_block
      elsif event_name and @events.has_key? event_name then
        @fsm.event = event_name
        @fsm.instance_eval &@events[event_name]
      elsif @events.has_key? :default then
        @fsm.event = :default
        @fsm.instance_eval &@events[:default]
      end
    end

    # The #build/#run method sets up the events as given in the build_block.
    # Only event method is supported within the build_block with the name of the event and an optional block supplied.
    # The operation for each such line is carried out by the #event method.
    def build(&build_block)
      self.instance_eval &build_block
    end

    alias_method :run, :build
    
  end

  # This class implements the finite-state machine.
  # FSM class exposes the states it contains and can trigger an event.
  # States are created on the fly first time it's referenced through index operator [].
  # 
  # The FSM state transits to the default state if the latest event does not define the next state.
  # If default state is not set, then state does not change on undefined state.
  # The initial state of the FSM is the first state mentioned.
  # This can be either the default state if defined or the first referenced state.
  #
  # == Usage
  #   fsm = FSM.new :default_state
  #   fsm[:default_state].event(:first_event) do # the state is defined and referenced at the same time
  #     puts "The first transition from the default_state to state_name"
  #     :state_name # the next state is defined here
  #   end
  #
  class FSM
    attr_writer :event
    def initialize(default_state=nil) 
      @states = {}
      if default_state then
        @state = @default = default_state 
        @states[@state] = FSMState.new(self, @state)
      end
    end
    
    def to_s() 
      "FSM" + 
        ": {" + 
          @states.values.map{ |st| 
            (st.state==@state ? ">" : "") + st.to_s
          }.join(', ') + 
        "}" 
    end
    
    # It returns the FSMState object for state_name.
    # If the state is missing, then it first sets up the state, and then returns the newly created state.
    def [](state_name=nil) 
      state_name ||= @state
      if state_name and not @states.has_key? state_name then
        @states[state_name] = FSMState.new(self, state_name)
        @state ||= state_name
      end
      @states[state_name]
    end

    # When the state_block is provided, it sets up a new state.
    # Otherwise, when the state_block is missing, the FSMState object for state_name is returned.
    # If called without any parameter, then the current state is returned.
    def state(state_name=nil, &state_block)
      if block_given? then
        self.[](state_name).build &state_block
      else
        self.[](state_name)
      end
    end
    
    # It triggers the event_name event and changes the state of the FSM to its new state.
    # The :entry and :exit events are called on the leaving state and the entering state.
    # If the event does not mention the new state, then the state changes to the default state.
    def event(event_name)
      @event = event_name 
      @states[@state].event :exit
      new_state = @states[@state].event event_name
      new_state = nil if not @states.has_key? new_state
      new_state ||= @default
      new_state ||= @state 
      @state = new_state
      @states[@state].event :enter
    end
    
    # The #build/#run method sets up the states and events as given in the build_block.
    # Only state and event methods are supported within the build_block with the name of the state/event and a block supplied.
    # The operation for each such line is carried out by the #state/#event method.
    def build(&build_block)
      self.instance_eval &build_block
    end
  
    alias_method :run, :build

  end

end