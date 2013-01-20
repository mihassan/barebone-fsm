require '../lib/barebone-fsm'

fsm = FSM::FSM.new(:default)

fsm.build do

  state :default do
    event :open do
      puts "#{@x} transition: default->open"
      :open
    end
    event :close do
      puts "#{@x} transition: default->close"
      :close
    end
  end

  state :open do
    event :close do
      @x ||= 0
      @x+=1
      puts "#{@x} transition: open->close"
      :close
    end
  end

  state :close do
    event :open do
      @x ||= 0
      @x+=1
      puts "#{@x} transition: close->open"
      :open
    end
  end

end

puts fsm

fsm.run do
  
  event :close
  event :open
  event :close
  event :undefined
  event :open
  event :close

end

puts fsm