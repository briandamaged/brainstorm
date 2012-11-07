require 'unobservable'

module Brainstorm


  class Start
  end
  
  def start
    Start.new
  end
  
  class Finish
  end
  
  def finish
    Finish.new
  end
  
  
  class Value
    attr_reader :value
    def initialize(value)
      @value = value
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


