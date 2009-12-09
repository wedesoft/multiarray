module Hornetseye

  class Sequence_ < CompositeType

    class << self

      attr_accessor :stride

      def inspect
        to_s
      end

      def default
        retval = new
        retval.set
        retval
      end

      def to_s
        if element_type
          shortcut = element_type < Sequence_ ? 'MultiArray' : 'Sequence'
          typename = typecode.to_s
          if typename =~ /^[A-Z]+$/
            "#{shortcut}.#{typename.downcase}(#{shape.join ','})"
          else
            "#{shortcut}(#{typename},#{shape.join ','})"
          end
        else
          'Sequence_'
        end
      end

      def typecode
        element_type.typecode
      end

      def empty?
        num_elements == 0
      end

      def shape
        element_type.shape + [ num_elements ]
      end

    end

    def stride
      self.class.stride
    end

    def inspect( indent = nil, lines = nil )
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
        for i in 0 ... num_elements
          x = at i
          if x.is_a? Sequence_
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

    def to_a
      ( 0 ... num_elements ).collect do |i|
        x = at i
        x.is_a?( Sequence_ ) ? x.to_a : x
      end
    end

    def set( value = typecode.default )
      if value.is_a? Array
        for i in 0 ... num_elements
          assign i, i < value.size ? value[ i ] : typecode.default
        end
      else
        op( value ) { |x| set x }
      end
      value
    end

    def get
      self
    end

    def sel( *indices )
      if indices.empty?
        super *indices
      else
        unless ( 0 ... num_elements ).member? indices.last
          raise "Index must be in 0 ... #{num_elements} " +
                "(was #{indices.last.inspect})"
        end
        element_memory = @memory + indices.last * stride * typecode.bytesize
        element_type.new( :memory => element_memory ).sel *indices[ 0 ... -1 ]
      end
    end

  end

  Sequence_.class_eval { include SequenceOperation }

  def Sequence( element_type, num_elements,
                stride = element_type.size )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval.stride = stride
    retval
  end

  module_function :Sequence

end
