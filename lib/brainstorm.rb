require 'unobservable'

module Brainstorm


  class Start
    def to_s
      "[START]"
    end
  end
  
  def start
    Start.new
  end
  
  class Finish
    def to_s
      "[FINISH]"
    end
  end
  
  def finish
    Finish.new
  end
  
  
  class Value
    attr_reader :value
    def initialize(value)
      @value = value
    end
    
    def to_s
      "[#{@value}]"
    end
  end
  
  
  def value(value)
    Value.new(value)
  end
  



  class Neuron
    include Unobservable::Support
    
    attr_event :fired
    
    def call(item)
      raise NotImplementedError, "Neuron is an abstact base class."
    end
    
    def >>(callable)
      self.fired.register {|i| callable.call(i) }
      return callable
    end
    
    private
    def fire(item)
      raise_event :fired, item
    end
  end

  class Forwarder < Neuron
    def call(item)
      fire item
    end
  end



  class Selector < Neuron
    attr_accessor :function
  
    def initialize(&block)
      @function = block
    end
  
    def call(item)
      if @function.call(item)
        fire start
        fire value(item)
        fire finish
      else
        fire value(item)
      end
    end
  end


  class Debouncer < Neuron
    attr_accessor :quiet_period
    attr_reader :timer, :state
  
    def initialize(quiet_period)
      @quiet_period = quiet_period
      
      @buffer = []

      @timer = 0
      @is_capturing = false
      @in_block = false
    end
    
    def call(item)
      puts item.class
      if item.is_a? Start
        if @is_capturing
          # Record the items that were in the debounce window
          @buffer.each {|i| fire i}
        else
          # Start recording items
          @is_capturing = true
          fire start
        end
        @in_block = true
        @timer = 0
      elsif item.is_a? Finish
        @buffer   = []
        @in_block = false
      elsif item.is_a? Value
        if @is_capturing
          if @in_block
            # Always fire items inside of blocks
            fire item
          else
            @timer += 1
            if @timer > @quiet_period
              fire finish
              @is_capturing = false
            else
              @buffer.push item
            end
          end
        end
      end

    end
  end


  class Aggregator < Neuron
    def initialize
      @buffer = []
      
      @is_capturing = false
    end
    
    def call(item)
      if @is_capturing
        if item.is_a? Start
          # TODO: Improve error-handling here
          $stderr.puts "Unexpected 'Start' token encountered"
        elsif item.is_a? Finish
          fire @buffer.dup
          @is_capturing = false
        elsif item.is_a? Value
          @buffer.push item.value
        else
          # TODO: Improve error-handling here
          $stderr.puts "Non-aggregate token encountered"
        end
      else
        if item.is_a? Start
          @buffer       = []
          @is_capturing = true
        elsif item.is_a? Finish
          # TODO: Improve error-handling here
          $stderr.puts "Unexpected 'Finish' token encountered"
        elsif item.is_a? Value
          # Just ignore the value
        else
          # TODO: Improve error-handling here
          $stderr.puts "Non-aggregate token encountered"
        end
      end
    end
  end



end


