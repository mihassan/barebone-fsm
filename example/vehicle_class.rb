require '../lib/barebone-fsm'

class Vehicle
  
  include FSM
  
  def initialize
    build do
      state :parked do event :start => :running, :open => :open end
      state :running do event park: :parked end
      state :open do event :park do :parked end end
    end
  end
  
  def show_fsm
    puts @fsm
  end
end

veh = Vehicle.new
veh.run do
  p self
  event :start, :park
  p self
  event :park
  p self
  event :open
  p self
  event :park
  p self
end
