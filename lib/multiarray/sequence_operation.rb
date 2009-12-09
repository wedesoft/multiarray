module Hornetseye

  module SequenceOperation

    def op( *args, &action )
      for i in 0 ... num_elements
        sub_args = args.collect do |arg|
          arg.is_a?( Sequence_ ) ? arg[ i ] : arg
        end
        sel( i ).op *sub_args, &action
      end
      self
    end

  end

end
