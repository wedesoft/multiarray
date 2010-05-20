module Hornetseye

  class MultiArray

    class << self

      def new( typecode, *shape )
        options = shape.last.is_a?( Hash ) ? shape.pop : {}
        count = options[ :count ] || 1
        if shape.empty?
          memory = typecode.memory.new typecode.storage_size * count
          Hornetseye::Pointer( typecode ).new memory
        else
          size = shape.pop
          stride = shape.inject( 1 ) { |a,b| a * b }
          Hornetseye::lazy( size ) do |index|
            pointer = new typecode, *( shape + [ :count => count * size ] )
            Lookup.new pointer, index, INT.new( stride )
          end
        end
      end

      def []( *args )
        retval = Node.fit( args ).new
        recursion = proc do |element,args|
          if element.dimension > 0
            args.each_with_index do |arg,i|
              recursion.call element.element( i ), arg
            end
          else
            element[] = args
          end
        end
        recursion.call retval, args
        retval
      end

    end

  end

  def MultiArray( element_type, *shape )
    if shape.empty?
      element_type
    else
      Hornetseye::Sequence MultiArray( element_type, *shape[ 0 ... -1 ] ),
                           shape.last
    end
  end

  module_function :MultiArray

end
