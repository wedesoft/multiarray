module Hornetseye

  class Lazy

    def initialize( *values )
      options = values.last.is_a?( Hash ) ? values.pop : {}
      @values = values
      if options[ :action ]
        @action = options[ :action ]
      else
        unless @values.size == 1
          raise "#{@values.size} value(s) where specified without defining " +
            ":action"
        end
        @action = proc { |*x| x.first }
      end
    end

    def inspect
      '<delayed>'
    end

    def force
      @action.call *@values.collect { |value| value.force }
    end

    def read
      Lazy.new self, :action => proc { |x| x.fetch }
    end

    def element( index )
      elements = @values.collect { |value| value.element index }
      Lazy.new( *( elements + [ :action => @action ] ) )
    end

    def -@
      Lazy.new self, :action => proc { |x| -x }
    end

    def +@
      self
    end

    def +( other )
      Lazy.new self, other, :action => proc { |x,y| x + y }
    end

  end

  def lazy
    previous = Thread.current[ :lazy ]
    Thread.current[ :lazy ] = true
    begin
      retval = yield
    ensure
      Thread.current[ :lazy ] = previous
    end
    retval
  end

  module_function :lazy

  def eager
    previous = Thread.current[ :lazy ]
    Thread.current[ :lazy ] = false
    begin
      retval = yield
    ensure
      Thread.current[ :lazy ] = previous
    end
    retval
  end

  module_function :eager

end
