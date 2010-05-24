module Hornetseye

  class Element < Node

    class << self

      def fetch( ptr )
        new ptr.load( self )
      end

      def coercion( other )
        if self == other
          self
        else
          x, y = other.coerce self
          x.coercion y
        end
      end

    end

    def initialize( value = self.class.default )
      @value = value
    end

    def descriptor( hash )
      "#{self.class.to_s}(#{@value.to_s})"
    end

    def demand
      if @value.respond_to? :demand
        self.class.new @value.demand( self.class )
      else
        self.class.new @value
      end
    end

    def strip
      variable = Variable.new self.class
      return [ variable ], [ self ], variable
    end

    def get
      @value
    end

    def store( value )
      if @value.respond_to? :store
        @value.store value.demand.get
      else
        @value = value.demand.get
      end
    end

    def write( ptr )
      ptr.save self
    end

  end

end
