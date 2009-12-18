module Hornetseye

  # Class for representing Ruby objects
  class OBJECT < Type

    class << self

      # Returns the type of storage object for storing values
      #
      # @return [Class] Returns +List+.
      #
      # @private
      #def storage
      #  List
      #end

      # Number of elements for storing an object of this type
      #
      # @return [Integer] Returns +1+.
      #
      # @private
      #def delegate_size
      #  1
      #end

      # @private
      def delegate( options = {} )
        mode = ( Thread.current[ :mode ] || Ruby )
        target = mode.const_get :OBJECT
        raise "No delegate #{mode}::OBJECT" if self == target
        target.new options
      end

      # Default value for Ruby objects.
      #
      # @return [Object] Returns +nil+. 
      #
      # @private
      def default
        nil
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

    end

  end

end
