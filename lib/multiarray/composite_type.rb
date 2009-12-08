module MultiArray

  class CompositeType < Type

    class << self

      attr_accessor :element_type
      attr_accessor :num_elements

      def memory
        element_type.memory
      end

      def bytesize
        element_type.bytesize * num_elements
      end

    end

    def element_type
      self.class.element_type
    end

    def num_elements
      self.class.num_elements
    end

    def sel( *indices )
      if indices.empty?
        super
      else
        unless ( 0 ... num_elements ).member? indices.last
          raise "Index must be in 0 ... #{num_elements} (was #{indices.last.inspect})"
        end
        element_type.new( @memory + indices.last * basetype.bytesize ).
          sel *indices[ 0 ... -1 ]
      end
    end

  end

end
