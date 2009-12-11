module Hornetseye

  # @private
  # @abstract
  class DescriptorType < Type

    class << self

      # @private
      def pack( value )
        [ value ].pack descriptor
      end

      # @private
      def unpack( value )
        value.unpack( descriptor ).first
      end

    end

  end

end
