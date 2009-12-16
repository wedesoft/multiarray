module Hornetseye

  # @private
  # @abstract
  class Compact < Type

    # @private
    def bytesize
      self.class.bytesize
    end

  end

end
