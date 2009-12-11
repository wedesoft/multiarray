module Hornetseye

  # Abstract class inherited by +Memory+ and +List+
  #
  # @see Memory
  # @see List
  #
  # @private
  # @abstract
  class Storage

    # Create storage object based on raw data or Ruby array
    #
    # @param [Malloc,Array] data Delegate object for storing the data.
    #
    # @private
    def initialize( data )
      @data = data
    end

  end

end
