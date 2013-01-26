require '../lib/barebone-fsm'

fsm = FSM::FSM.new

fsm.build do

  state :stopped do
    event :open do
      puts "[#{@state}]->#{@event}"
      :open
    end
    event :start do
      puts "[#{@state}]->#{@event}"
      :started
    end
  end
  
  state :open do
    event :close do
      puts "[#{@state}]->#{@event}"
      :stopped
    end
  end
  
  state :started do
    event :open do
      puts "[#{@state}]->#{@event}"
      :open
    end
    event :stop do
      puts "[#{@state}]->#{@event}"
      :stopped
    end
  end

end

fsm.run do
  
  event :open
  event :close
  event :start
  event :open
  event :close
  event :start
  event :stop
  
end

puts fsm