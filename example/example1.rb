require '../lib/barebone-fsm'

fsm = FSM::FSM.new(:default)
fsm.build do
  state :default do
    event :start do
      puts "default->open #{@state},#{@event},(#{@x})"
      :open
    end
    event :default do
      puts "default->default #{@state},#{@event},(#{@x})"
      :open
    end
    event :entry do
      puts "default enetered"
    end
  end
  state :open do
    event :close do
      @x ||= 0
      @x+=1
      puts "open->close #{@state},#{@event},(#{@x})"
      :close
    end
  end
  state :close do
    event :open do
      @x ||= 0
      @x+=1
      puts "close->open #{@state},#{@event},(#{@x})"
      :open
    end
  end
  event :starts
  event :close
  event :open
  event :close
end

puts fsm