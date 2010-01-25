module Hornetseye

  # Class for representing Ruby objects
  class OBJECT < Type

    class << self

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

      def fetch( ptr )
        new ptr.read
      end

      # Default value for Ruby objects
      #
      # @return [Object] Returns +nil+.
      #
      # @private
      def default
        nil
      end

      def size
        1
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

  end

  module RubyMatching

    def fit( *value )
      OBJECT
    end

  end

  Type.extend RubyMatching

end
