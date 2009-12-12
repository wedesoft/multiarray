module Hornetseye

  # Abstract class for representing multi-dimensional arrays
  #
  # @see #Sequence
  # @see #MultiArray
  # @see Sequence
  # @see MultiArray
  #
  # @abstract
  class Sequence_ < CompositeType

    class << self

      # Distance of two consecutive elements divided by size of single element
      #
      # @return [Integer] Stride size to iterate over array.
      #
      # @see #Sequence
      # @see List#+
      # @see Memory#+
      #
      # @private
      attr_accessor :stride

      # Get string with information about this type
      #
      # @return [String] Information about this array type.
      def inspect
        to_s
      end

      # Get default value for this array type.
      #
      # @return [Object] Returns a multi-dimensional array filled with the
      # default value of the element type.
      #
      # @private
      def default
        retval = new
        retval.set
        retval
      end

      # Get string with information about this type
      #
      # @return [String] Information about this array type.
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

      # Returns the element type of this array
      #
      # @return [Class] Returns +element_type.typecode+.
      def typecode
        element_type.typecode
      end

      # Check whether arrays of this type are empty or not
      #
      # @return [FalseClass,TrueClass] Returns boolean indicating whether
      # arrays of this type are empty or not.
      def empty?
        num_elements == 0
      end

      # Get shape of multi-dimensional array
      #
      # @return [Array<Integer>] Ruby array with the shape of this array type.
      def shape
        element_type.shape + [ num_elements ]
      end

    end

    # Distance of two consecutive elements divided by size of single element
    #
    # @return [Integer] Stride size to iterate over array.
    #
    # @see #Sequence
    # @see List#+
    # @see Memory#+
    #
    # @private
    def stride
      self.class.stride
    end

    # Display type and values of this array
    #
    # @return [String] Returns string with information about the type and the
    # values of this array.
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

    # Display values of this array
    #
    # @return [String] Returns string with the values of this array.
    def to_s
      to_a.to_s
    end

    # Convert to Ruby array
    #
    # @return [Array<Object>] Result of the conversion.
    def to_a
      ( 0 ... num_elements ).collect do |i|
        x = at i
        x.is_a?( Sequence_ ) ? x.to_a : x
      end
    end

  end

end
