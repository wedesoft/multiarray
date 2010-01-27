module Hornetseye

  class Pointer_ < Type

    class << self

      attr_accessor :primitive

      def inspect
        if primitive
          if primitive < Sequence_
            primitive.inspect
          else
            "Pointer(#{primitive.inspect})"
          end
        else
          super
        end
      end

      def to_s
        if primitive
          if primitive < Sequence_
            primitive.to_s
          else
            "Pointer(#{primitive.to_s})"
          end
        else
          super
        end
      end
      
      def default
        if Thread.current[ :lazy ]
          Lazy.new :action => proc { self.class.primitive.typecode.new }
        else
          primitive.memory.new primitive.storage_size
        end
      end

      def dereference
        primitive.dereference
      end

      def to_type( typecode, options = {} )
        Hornetseye::Pointer primitive.to_type( typecode, options )
      end

      def coercion( other )
        if other < Pointer_
          Hornetseye::Pointer primitive.coercion( other.primitive )
        else
          Hornetseye::Pointer primitive.coercion( other )
        end
      end

      def coerce( other )
        if other < Pointer_
          return other, self
        else
          super other
        end
      end

    end

    def inspect( indent = nil, lines = nil )
      if self.class.primitive < Sequence_
        if @value.is_a? Lazy
          "#{self.class.primitive.inspect}:#{@value.inspect}"
        else
          if indent
            prepend = ''
          else
            prepend = "#{self.class.inspect}:\n"
            indent = 0
            lines = 0
          end
          if empty?
            retval = '[]'
          else
            retval = '[ '
            for i in 0 ... self.class.primitive.num_elements
              x = self[i]
              if x.is_a? Pointer_
                if i > 0
                  retval += ",\n  "
                  lines += 1
                  if lines >= 10
                    retval += '...' if indent == 0
                    break
                  end
                  retval += '  ' * indent
                end
                str = x.inspect indent + 1, lines
                lines += str.count "\n"
                retval += str
                if lines >= 10
                  retval += '...' if indent == 0
                  break
                end
              else
                retval += ', ' if i > 0
                str = x.inspect
                if retval.size + str.size >= 74 - '...'.size -
                    '[  ]'.size * indent.succ
                  retval += '...'
                  break
                else
                  retval += str
                end
              end
            end
            retval += ' ]' unless lines >= 10
          end
          prepend + retval
        end
      else
        super()
      end
    end

    def to_a
      if self.class.primitive < Sequence_
        ( 0 ... self.class.primitive.num_elements ).collect do |i|
          element( i ).to_a
        end
      else
        force.fetch.get
      end
    end

    def []( *args )
      if args.empty?
        if self.class.primitive < Sequence_
          self
        else
          fetch[]
        end
      else
        index = args.pop
        case index
        when Range
          elements( index )[ *args ]
        else
          element( index )[ *args ]
        end
      end
    end

    def []=( *args )
      value = args.pop
      if args.empty?
        if self.class.primitive < Sequence_
          if value.is_a? Array
            for i in 0 ... self.class.primitive.num_elements
              if i < value.size
                element( i )[] = value[ i ]
              else
                element( i )[] = self.class.primitive.typecode.default
              end
            end
          else
            operation( self.class.primitive.new( value ) ) { |x| set x }
          end
        else
          store self.class.primitive.new( value )
        end
      else
        index = args.pop
        element( index )[ *args ] = value
      end
    end

    def set( value )
      unless value.is_a?( List ) or value.is_a?( Malloc ) or
          value.is_a?( Lazy )
        store self.class.primitive.new( value )
      else
        super value
      end
      value
    end

    def fetch
      if self.class.primitive < Sequence_
        delay
      else
        get.fetch self.class.primitive
      end
    end

    def force
      if Thread.current[ :lazy ] or not @value.is_a? Lazy
        self
      else
        if self.class.primitive < Sequence_ and @value.is_a? Lazy
          self.class.new.operation( self ) { |x| set x }
        else
          super
        end
      end
    end

    def store( value )
      value.force.store @value
    end

    def element( index )
      target = Hornetseye::Pointer self.class.primitive.element_type
      if @value.is_a? Lazy
        target.new @value.element( index )
      else
        pointer = @value + index * self.class.primitive.stride *
          self.class.primitive.typecode.storage_size
        target.new pointer
      end
    end

    def elements( range )
      target = Sequence self.class.primitive.element_type, range.size,
                        self.class.primitive.stride
      if @value.is_a? Lazy
        target.new @value.elements( range )
      else
        pointer = @value + range.min * self.class.primitive.stride *
          self.class.primitive.typecode.storage_size
        target.new pointer
      end
    end

    def empty?
      self.class.primitive.size == 0
    end

    def operation( *args, &action )
      if self.class.primitive < Sequence_
        if Thread.current[ :lazy ]
          super *args.collect { |arg| arg.delay }, &action
        else
          for i in 0 ... self.class.primitive.num_elements
            subargs = args.collect do |arg|
              if arg.is_a?( Pointer_ ) and arg.class.primitive < Sequence_
                arg.element( i ).fetch
              else
                arg.force.fetch
              end
            end
            element( i ).operation *subargs, &action
          end
          self
        end
      else
        super *args, &action
      end
    end

  end

end
