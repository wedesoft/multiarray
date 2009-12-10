module Hornetseye

  module SequenceOperation

    def set( value = typecode.default )
      puts 'Sequence_#set'
      if value.is_a? Array
        for i in 0 ... num_elements
          assign i, i < value.size ? value[ i ] : typecode.default
        end
      else
        op( value ) { |x| set x }
      end
      value
    end

    def get
      puts 'Sequence_#get'
      self
    end

    def sel( *indices )
      puts 'Sequence_#sel'
      if indices.empty?
        super *indices
      else
        unless ( 0 ... num_elements ).member? indices.last
          raise "Index must be in 0 ... #{num_elements} " +
                "(was #{indices.last.inspect})"
        end
        element_memory = @memory + indices.last * stride * typecode.bytesize
        element_type.wrap( element_memory ).sel *indices[ 0 ... -1 ]
      end
    end

    def op( *args, &action )
      puts 'Sequence_#op'
      for i in 0 ... num_elements
        sub_args = args.collect do |arg|
          arg.is_a?( Sequence_ ) ? arg[ i ] : arg
        end
        sel( i ).op *sub_args, &action
      end
      self
    end

  end

  Sequence_.class_eval { include SequenceOperation }

end
