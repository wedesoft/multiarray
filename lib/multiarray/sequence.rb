module Hornetseye

  class Sequence_ < CompositeType

    class << self

      attr_accessor :stride

      def inspect
        to_s
      end

      def to_s
        "Sequence(#{element_type.to_s},#{num_elements.to_s})"
      end

      def typecode
        element_type.typecode
      end

      def shape
        element_type.shape + [ num_elements ]
      end

    end

    def stride
      self.class.stride
    end

    def to_a
      ( 0 ... num_elements ).collect do |i|
        x = at i
        x.is_a?( Sequence_ ) ? x.to_a : x
      end
    end

    def get
      self
    end

    def sel( *indices )
      if indices.empty?
        super *indices
      else
        unless ( 0 ... num_elements ).member? indices.last
          raise "Index must be in 0 ... #{num_elements} " +
                "(was #{indices.last.inspect})"
        end
        element_memory = @memory + indices.last * stride * typecode.bytesize
        element_type.new( :memory => element_memory ).sel *indices[ 0 ... -1 ]
      end
    end

  end

  def Sequence( element_type, num_elements,
                stride = element_type.size )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval.stride = stride
    retval
  end

  module_function :Sequence

end
