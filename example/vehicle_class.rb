require_relative 'example_helper'

class Vehicle
  
  include FSM
  
  def initialize
    build do
      state :parked do event :start => :running, :open => :open end
      state :running do event :park => :parked end
      state :open do event :park => :parked end
    end
  end
  
  def show_fsm
    puts @fsm
  end
end

veh = Vehicle.new

puts "It is parked" if veh.is_parked?

puts "It can start" if veh.can_start?

veh.start

puts veh.state

veh.state :turned_off
veh.state :parked do event :turn_off => :turned_off end
veh.event :turn_off

puts "It is parked" if veh.is_parked?

puts "It can start" if veh.can_start?

#veh.start