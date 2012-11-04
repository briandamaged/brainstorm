require 'unobservable'

module Brainstorm
  
  class Neuron
    include Unobservable::Support
    
    attr_event :fired
    
    def <<(item)
      raise_event :fired, item
    end
  end
  
end


