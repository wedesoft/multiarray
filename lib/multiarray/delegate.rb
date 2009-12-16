module Hornetseye

  # Abstract class inherited by +Ruby::Memory+ and +Ruby::List+
  #
  # @see Ruby::Memory
  # @see Ruby::List
  #
  # @private
  # @abstract
  class Storage

    # Create storage object based on raw data or Ruby array
    #
    # @param [Ruby::Memory,Ruby::List] data Delegate object for storing the
    # data.
    #
    # @private
    def initialize( data )
      @data = data
    end

  end

end
