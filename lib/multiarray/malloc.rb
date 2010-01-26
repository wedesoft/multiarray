module Hornetseye

  class Malloc

    def fetch( type )
      type.import read( type.storage_size )
    end

  end

end
