module Hornetseye

  # Class for representing Ruby objects
  class OBJECT < Type

    class << self

      # Get memory type for storing objects of this type
      #
      # @return [Class] Returns +List+.
      #
      # @see List
      #
      # @private
      def memory
        List
      end

      # Get string with information about this type
      #
      # @return [String] Returns +'OBJECT'+.
      def to_s
        'OBJECT'
      end

      # Get string with information about this type
      #
      # @return [String] Returns +'OBJECT'+.
      def inspect
        to_s
      end

      # Default value for Ruby objects
      #
      # @return [Object] Returns +nil+.
      #
      # @private
      def default
        nil
      end

      # Size of storage required to store an element of this type
      #
      # @return [Integer] Size of storage required. Returns +1+.
      #
      # @private
      def storage_size
        1
      end

    end

    def store( ptr )
      ptr.write @value
      self
    end

    raise '\'multiarray/object\' must be loaded first' if Type.respond_to? :fit

    module RubyMatching

      def fit( *values )
        OBJECT
      end

    end

    Type.extend RubyMatching

  end

end
