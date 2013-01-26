##
# This module implements a basic finite-state machine (FSM).
# An FSM consists of a finite number of states,
# with one of them being the current state of the FSM.
# Transitions are defined between states, which are triggered on events.
# For details on FSM, see this wiki page: {FSM}[http://en.wikipedia.org/wiki/Finite-state_machine].
#
# The motivation behind the module was to implement a very basic barebone {FSM} in Ruby.
# Features are kept at minimum as well as the code.
# Only two classes for the FSM are defined as the following:
# * {FSM::FSM} -> the finite state machine class
# * {FSM::FSMState} -> the state class
# The {FSM} Module when included in a class also provides few convenience methods.
# For further details see the README file.
#
# Author:: Md. Imrul Hassan (mailto:mihassan@gmail.com)
# Copyright:: Copyright (c) 2013, Md. Imrul Hassan
# License:: Barebone-fsm is released under the MIT license
#
module FSM
  
  ##
  # FSMState class represents a state of the finite state machine.
  # 
  # @example Setup the event code for a state through block
  #   state = FSM::FSMState.new :state_name
  #   state.event(:event_name) do
  #     puts "#{@event} triggered on state #{@state}"
  #     :next_state
  #   end  
  #
  # @example Setup multiple events specifying only the next state for each event using Hash map
  #   state = FSM::FSMState.new :initial_state
  #   state.event :go_left => :left_state, :go_right => :right_state
  #
  # @example Trigger an event for the previous example
  #   state.event :go_left
  #
  class FSMState

    ##
    # The name of the state.
    attr_reader :state
    ##
    # The events for this state mapped to corresponding event codes.
    attr_reader :events

    ##
    # @param state_machine [FSM::FSM] the FSM object representing the state machine containing this state
    # @param state_name [Symbol] the unique name for this state
    #
    def initialize(state_machine, state_name) 
      @fsm = state_machine
      @state = state_name
      @events = {}
    end
    
    ##
    # A String representation of the FSMState object.
    def to_s() 
      @state.to_s + 
        ": [" + 
          @events.keys.map(&:to_s).join(', ') + 
        "]" 
    end

    ##
    # Setup or trigger an event.
    # It sets up a new event when the event_block is provided or event_name is a Hash map.
    # The event_name is triggered otherwise. 
    # If the event is nil or not already setup, then the default event is triggered.
    #
    # @overload event(event_name, &event_block)
    #   Sets up an event for this state with the given event_block parameter.
    #   @param event_name [Symbol] the name of the event to set up
    #   @param event_block [block] the block of code to run when this event will be triggered
    #
    # @overload event(events_hash)
    #   Sets up multiple events where each element of the Hash map corresponds to one event.
    #   @param events_hash [Hash<Symbol,Symbol>] the Hash object mapping events to the corresponding next states
    #
    # @overload event(event_name)
    #   Triggers the event named event_name for this state.
    #   @param event_name [Symbol] the name of the event to trigger
    #
    # @example Setup an event by block
    #   state.event(:event_name) do
    #     puts "#{@event} triggered on state #{@state}"
    #     :next_state
    #   end  
    #
    # @example Setup an event by Hash
    #   state.event :go_left => :left_state, :go_right => :right_state
    #
    # @example Trigger an event
    #   state.event :go_left
    #
    def event(event_name, &event_block)
      if block_given? then
        @events[event_name] = event_block
      elsif event_name.is_a?(Hash) then
        event_name.each{ |ev, st|
          @events[ev] = Proc.new{st}
        }
      elsif event_name and @events.has_key? event_name then
        @fsm.event = event_name
        @fsm.instance_eval &@events[event_name]
      elsif @events.has_key? :default then
        @fsm.event = :default
        @fsm.instance_eval &@events[:default]
      end
    end

    ##
    # The #build/#run method sets up the events described as DSL code in the build_block.
    # Only event method is supported within the build_block with the name of the event and an optional block supplied.
    # The operation for each such line is carried out by the {FSM::FSMState#event} method.
    # @see FSM::FSMState#event
    #
    # @param build_block [block] the block of code with sevaral event methods
    #
    # @example Using block to setup events
    #   state.build do
    #     event :event_name do
    #       puts "#{@event} triggered on state #{@state}"
    #       :next_state
    #     end
    #   end
    #
    # @example Using block to trigger events
    #   state.build do
    #     event :event_name
    #   end
    #
    def build(&build_block)
      self.instance_eval &build_block
    end

    alias_method :run, :build
    
  end

  ##
  # This class implements the finite-state machine.
  # FSM class exposes the states it contains and can trigger an event.
  # States are created on the fly first time it's referenced through index operator [] or #state method.
  # 
  # The FSM state transits to the default state if the latest event does not define the next state.
  # If default state is not set, then state does not change on undefined state.
  # The initial state of the FSM is the first state mentioned.
  # This can be either the default state if defined or the first referenced state.
  #
  # @example Setting up finite state machine and triggering events without blocks
  #   fsm = FSM::FSM.new(:default_state)
  #   fsm[:default_state].event(:first_event) do
  #     puts "The first transition from the default_state to state_name"
  #     :state_name
  #   end
  #   fsm.event :first_event
  #
  # @example Setting up finite state machine and triggering events with blocks
  #   fsm = FSM::FSM.new
  #   fsm.build do
  #     state :initial_state do
  #       event :an_event => :next_state
  #     end
  #   end
  #   fsm.run do
  #     event :an_event
  #   end
  #
  class FSM
    
    ##
    # The list of all the states.
    attr_reader :states
    
    ##
    # Creates a new FSM object with an optional default state.
    # @param default_state [Symbol] the name for the default state
    #
    # @example Create a new finite state machine without default state
    #   fsm = FSM::FSM.new
    #
    # @example Create a new finite state machine with default state
    #   fsm = FSM::FSM.new(:default_state)
    #
    def initialize(default_state=nil) 
      @states = {}
      if default_state then
        @default = default_state 
        @states[@default] = FSMState.new(self, @default)
      end
    end

    ##
    # A String representation of the FSM object.    
    def to_s() 
      "FSM" + 
        ": {" + 
          @states.values.map{ |st| 
            (st.state==@state ? ">" : "") + st.to_s
          }.join(', ') + 
        "}" 
    end
    
    ##
    # Creates and/or returns an FSMState object.
    # If an FSMState object with state_name is present, then returns that object.
    # Otherwise, it creates a new FSMState object first and then returns that object.
    # If state_name is not given, then current state object is returned.
    #
    # @overload []()
    #   The current FSMState object is returned.
    #
    # @overload [](state_name)
    # Returns the FSMState object with state_name.
    # If it is not setup yet, a new FSMState object is created first and then returned.
    #
    # @example
    #   fsm = FSM::FSM.new
    #   new_state = fsm[:new_state]
    #   print fsm[:new_state].state
    # 
    def [](state_name=nil) 
      state_name ||= @state
      if state_name and not @states.has_key? state_name then
        @states[state_name] = FSMState.new(self, state_name)
        @state ||= state_name
      end
      @states[state_name]
    end

    ##
    # Sets up and/or returns an FSMState object.
    # It sets up a new state with all its events when the state_block is provided.
    # If state_block is missing, then it creates and/or returns an FSMState object with state_name.
    # If state_name is not given, then current state object is returned.
    #
    # @overload state(state_name, state_block)
    #   Sets up a state with the given state_block parameter.
    #   @param state_name [Symbol] the name of the state to set up
    #   @param state_block [block] the block of code to setuo the state
    #
    # @overload state(state_name)
    #   Create and/or return a state object.
    #   @param state_name [Symbol] the name of the state
    #
    # @overload state()
    #   Return current state object.
    #
    # @example Setup a state by block
    #   fsm = FSM::FSM.new
    #   new_state = fsm.state(:new_state) do 
    #     event :an_event => :next_state
    #   end
    #
    # @example Create a new state
    #   fsm = FSM::FSM.new
    #   new_state = fsm.state(:new_state)
    #
    # @example Return the current state
    #   fsm = FSM::FSM.new
    #   new_state = fsm.state(:new_state)
    #   print fsm.state.state
    #
    def state(state_name=nil, &state_block)
      if block_given? then
        self.[](state_name).build &state_block
      else
        self.[](state_name)
      end
    end
    
    ##
    # Trigger a series of events.
    # The :entry and :exit events are called on the leaving state and the entering state.
    # If the event does not mention the new state, then the state changes to the default state.
    #
    # @param event_names [Array<Symbol>] the list of event names
    #
    # @example Triggers two events
    #   state.event(:first_event, :second_event)
    #
    def event(*event_names)
      for event_name in event_names do
        @event = event_name 
        @states[@state].event :exit
        new_state = @states[@state].event event_name
        new_state = nil if not @states.has_key? new_state
        new_state ||= @default
        new_state ||= @state 
        @state = new_state
        @states[@state].event :enter
      end
    end
    
    # @private
    def event=(event_name)
      @event = event_name
    end
    
    ##
    # The #build/#run method sets up the states and events as DSL code in the build_block.
    # Only state and event methods are supported within the build_block with the name of the state/event and an optional block supplied.
    # The operation for each such line is carried out by the #state/#event method.
    # @see FSM::FSM#state
    # @see FSM::FSM#event
    #
    # @example Using block to setup states and trigger events
    #   fsm = FSM::FSM.new
    #   fsm.build do
    #     state :stopped do
    #       event :run => :running
    #     end
    #     state :running do
    #       event :stop => :stopped
    #     end
    #   end
    #   fsm.run do
    #     event :run, :stop
    #   end
    #
    def build(&build_block)
      self.instance_eval &build_block
    end
  
    alias_method :run, :build

  end

  ##
  # The #build/#run method sets up the states and events as DSL code.
  # Only state and event methods are supported within the build_block with the name of the state/event and an optional block supplied.
  # The operation for each such line is carried out by the {FSM::FSM#state}/{FSM::FSM#event} method.
  # @see FSM::FSM#state
  # @see FSM::FSM#event
  #
  # @example Using block to setup states and trigger events
  #   fsm = FSM::FSM.new
  #   fsm.build do
  #     state :stopped do
  #       event :run => :running
  #     end
  #     state :running do
  #       event :stop => :stopped
  #     end
  #   end
  #   fsm.run do
  #     event :run, :stop
  #   end
  #
  def build(&build_block)
    @fsm ||= FSM.new
    @fsm.build(&build_block)
  end
  alias_method :run, :build
  
  ##
  # Trigger a series of events.
  # The :entry and :exit events are called on the leaving state and the entering state.
  # If the event does not mention the new state, then the state changes to the default state.
  # @param event_names [Array<Symbol>] the list of event names
  # @see FSM::FSM#event
  #
  def event(*event_names)
    @fsm.event(*event_names)
  end

  ##
  # Sets up and/or returns an FSMState object.
  # It sets up a new state with all its events when the state_block is provided.
  # If state_block is missing, then it creates and/or returns an FSMState object with state_name.
  # If state_name is not given, then current state object is returned.
  # @see FSM::FSM#state
  #
  # @overload state(state_name, state_block)
  #   Sets up a state with the given state_block parameter.
  #   @param state_name [Symbol] the name of the state to set up
  #   @param state_block [block] the block of code to setuo the state
  #
  # @overload state(state_name)
  #   Create and/or return a state object.
  #   @param state_name [Symbol] the name of the state
  #
  # @overload state()
  #   Return current state object.
  #  
  def state(state_name=nil, &state_block)
    @fsm.state(state_name, &state_block)
  end
  
  # The list of names of all the states
  def states
    @fsm.states.keys
  end

  ##
  # @!method is_state?
  #   Checks if the current state is state.
  #
  #   @example Vehicle running
  #     class Vehicle
  #       include FSM
  #       def initialize
  #         build do
  #           state :parked do event :start => :running end
  #           state :running do event :park => :parked end
  #         end
  #       end
  #     end
  #     veh = Vehicle.new
  #     puts "Vehicle running." if veh.is_running?
  #     veh.start
  #     puts "Vehicle running." if veh.is_running?
  
  ##
  # @!method can_trigger?
  #   Checks if trigger is an event on the current state.
  #
  #   @example Vehicle start if it can
  #     class Vehicle
  #       include FSM
  #       def initialize
  #         build do
  #           state :parked do event :start => :running end
  #           state :running do event :park => :parked end
  #         end
  #       end
  #     end
  #     veh = Vehicle.new
  #     veh.start if veh.can_start?

  ##
  # @!method trigger
  #   Triggers the evnt for current state.
  #   It should be used with #can_trigger? method, as if the method is only defined id it can be triggered.
  #
  # @example Vehicle start if it can
  #   class Vehicle
  #     include FSM
  #     def initialize
  #       build do
  #         state :parked do event :start => :running end
  #         state :running do event :park => :parked end
  #       end
  #     end
  #   end
  #   veh = Vehicle.new
  #   # veh.park will generate NoMethodError as vehicle can not park from parked state
  #   veh.park if veh.can_park?
  #   veh.start if veh.can_start?

  def respont_to?(sym)
    if @fsm then
      match_can_method?(sym) || match_is_method?(sym) || match_run_method?(sym) || super
    end
  end
  
  def method_missing(sym, *args, &block)
    if match = match_can_method?(sym) then
      @fsm.state.events.include?(match)
    elsif match = match_is_method?(sym) then
      @fsm.state.state == match
    elsif match = match_run_method?(sym) 
      @fsm.event(match)
    else 
      super
    end
  end

  private

  def match_can_method?(sym)
    sym.to_s =~ /can_(.*)\?/; $1 && $1.to_sym
  end

  def match_is_method?(sym)
    sym.to_s =~ /is_(.*)\?/; $1 && $1.to_sym
  end
 
  def match_run_method?(sym)
    @fsm.state.events.include?(sym)
  end

end