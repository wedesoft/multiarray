module Hornetseye

  class Sequence

    class << self

      def new( typecode, size )
        MultiArray.new typecode, size
      end

      def []( *args )
        target = Node.fit args
        target = Hornetseye::Sequence OBJECT, args.size if target.dimension > 1
        retval = target.new
        args.each_with_index { |arg,i| retval[ i ] = arg }
        retval
      end

    end

  end

  class Sequence_

    class << self

      attr_accessor :element_type
      attr_accessor :num_elements

      def shape
        element_type.shape + [ num_elements ]
      end

      def typecode
        element_type.typecode
      end

      def pointer_type
        self
      end

      def dimension
        element_type.dimension + 1
      end

      def contiguous
        self
      end

      def bool
        Hornetseye::Sequence element_type.bool, num_elements
      end

      def bool_binary( other )
        coercion( other ).bool
      end

      def inspect
        if dimension == 1
          "Sequence(#{typecode.inspect},#{num_elements.inspect})"
        else
          "MultiArray(#{typecode.inspect},#{shape.join ','})"
        end
      end

      def descriptor( hash )
        if dimension == 1
          "Sequence(#{typecode.descriptor( hash )},#{num_elements.to_s})"
        else
          "MultiArray(#{typecode.descriptor( hash )},#{shape.join ','})"
        end
      end

      def coercion( other )
        if other < Sequence_
          Hornetseye::Sequence element_type.coercion( other.element_type ),
                               num_elements
        else
          Hornetseye::Sequence element_type.coercion( other ),
                               num_elements
        end
      end

      def coerce( other )
        if other < Sequence_
          return other, self
        else
          return Hornetseye::Sequence( other, num_elements ), self
        end
      end

      def new
        MultiArray.new typecode, *shape
      end

    end

    module Match

      def fit( *values )
        n = values.inject 0 do |size,value|
          value.is_a?( Array ) ? [ size, value.size ].max : size
        end
        if n > 0
          elements = values.inject [] do |flat,value|
            flat + ( value.is_a?( Array ) ? value : [ value ] )
          end
          Hornetseye::Sequence fit( *elements ), n
        else
          super *values
        end
      end

    end

    Node.extend Match

  end

  def Sequence( element_type, num_elements )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval
  end

  module_function :Sequence

end
