module Hornetseye

  # Abstract class for describing scalar data types
  #
  # This class is for descriping scalar data types which are known to the Ruby
  # standard library. I.e. there is a descriptor for +Array#pack+ and
  # +String#unpack+.
  #
  # @see Array#pack
  # @see String#unpack
  #
  # @private
  # @abstract
  class DescriptorType < Type

    class << self

      # Convert a Ruby object to a string containing the native representation
      #
      # @return [String] A string with the native representation of the value.
      #
      # @see Array#pack
      #
      # @private
      def pack( value )
        [ value ].pack descriptor
      end

      # Convert a string with the native representation to a Ruby object
      #
      # @return [Object] The corresponding Ruby object to the native value.
      #
      # @see String#unpack
      #
      # @private
      def unpack( value )
        value.unpack( descriptor ).first
      end

    end

  end

end
