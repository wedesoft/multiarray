module Hornetseye

  # Abstract class for representing multi-dimensional arrays
  #
  # @see #Sequence
  # @see #MultiArray
  # @see Sequence
  # @see MultiArray
  #
  # @abstract
  class Sequence_ < Type

    class << self

      # Get memory type for storing objects of this type
      #
      # @return [Class] Returns +element_type.memory+.
      #
      # @see Malloc
      #
      # @private
      def memory
        element_type.memory
      end

      # Type of elements this type is composed of
      #
      # @return [Type,Sequence_] The element type of this type.
      attr_accessor :element_type

      # Number of elements this type is composed of
      #
      # @return [Integer] The number of elements this type is composed of.
      attr_accessor :num_elements

      # Distance of two consecutive elements divided by size of single element
      #
      # @return [Integer] Stride size to iterate over array.
      #
      # @see #Sequence
      # @see List#+
      # @see Malloc#+
      #
      # @private
      attr_accessor :stride

      def fetch( ptr )
        new ptr
      end

      # Get string with information about this type
      #
      # @return [String] Information about this array type.
      def inspect
        if element_type and num_elements
          shortcut = element_type < Sequence_ ? 'MultiArray' : 'Sequence'
          typename = typecode.inspect
          if typename =~ /^[A-Z]+$/
            "#{shortcut}.#{typename.downcase}(#{shape.join ','})"
          else
            "#{shortcut}(#{typename},#{shape.join ','})"
          end
        else
          super
        end
      end

      # Get string with information about this type
      #
      # @return [String] Information about this array type.
      def to_s
        if element_type and num_elements
          shortcut = element_type < Sequence_ ? 'MultiArray' : 'Sequence'
          typename = typecode.to_s
          if typename =~ /^[A-Z]+$/
            "#{shortcut}.#{typename.downcase}(#{shape.join ','})"
          else
            "#{shortcut}(#{typename},#{shape.join ','})"
          end
        else
          super
        end
      end

      # Returns the element type of this array
      #
      # @return [Class] Returns +element_type.typecode+.
      def typecode
        element_type.typecode
      end

      def size
        num_elements * element_type.size
      end

      def shape
        element_type.shape + [ num_elements ]
      end

      def storage_size
        element_type.storage_size * num_elements
      end

    end

  end

end
