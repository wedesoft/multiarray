module Hornetseye

  class DescriptorType < Type

    class << self

      def pack( value )
        [ value ].pack descriptor
      end

      def unpack( value )
        value.unpack( descriptor ).first
      end

    end

  end

end
