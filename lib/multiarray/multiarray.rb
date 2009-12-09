module Hornetseye

  def MultiArray( element_type, *shape )
    if shape.empty?
      element_type
    else
      MultiArray Sequence( element_type, shape.first ), *shape[ 1 .. -1 ]
    end
  end

  module_function :MultiArray

end
