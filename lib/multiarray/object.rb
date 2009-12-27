module Hornetseye

  # Class for representing Ruby objects
  class OBJECT < Type

    class << self

      # Get delegate class to this class
      #
      # @return [Ruby::OBJECT] Delegate class.
      #
      # @private
      def delegate
        mode = ( Thread.current[ :mode ] || Ruby )
        mode.const_get :OBJECT
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
