module Hornetseye

  # @private
  # @abstract
  class Compact < Type

    # Get number of bytes memory required to store the data of an instance
    #
    # @return [Integer] Number of bytes.
    #
    # @private
    def bytesize
      self.class.bytesize
    end

  end

end
