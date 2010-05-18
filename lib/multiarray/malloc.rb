module Hornetseye

  class Malloc

    def load( typecode )
      read( typecode.storage_size ).unpack( typecode.directive ).first
    end

    def save( value )
      write [ value.get ].pack( value.typecode.directive )
      value
    end

  end

end
