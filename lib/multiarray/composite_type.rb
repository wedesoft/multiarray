module Hornetseye

  # @abstract
  class CompositeType < Type

    class << self

      attr_accessor :element_type

      attr_accessor :num_elements

      # @private
      def memory
        element_type.memory
      end

      def bytesize
        element_type.bytesize * num_elements
      end

      # @private
      def basetype
        element_type.basetype
      end

    end

    def element_type
      self.class.element_type
    end

    def num_elements
      self.class.num_elements
    end

  end

end
