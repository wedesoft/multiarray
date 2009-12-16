module Hornetseye

  # Boolean constant to use as a parameter for creating integer classes
  #
  # The value is +false+.
  #
  # @see #INT
  UNSIGNED = false

  # Boolean constant to use as a parameter for creating integer classes
  #
  # The value is +true+.
  #
  # @see #INT
  SIGNED   = true

  # Create a class deriving from +INT_+
  #
  # The parameters +bits+ and +signed+ are assigned to the corresponding
  # attributes of the resulting class.
  #
  # @param [Integer] bits Number of bits of native integer.
  # @param [FalseClass,TrueClass] signed Specify +UNSIGNED+ or +SIGNED+ here.
  # @return [Class] A class deriving from +INT_+.
  #
  # @see INT_
  # @see INT_.bits
  # @see INT_.signed
  def INT( bits, signed )
    target = ( Thread.current[ :mode ] || Ruby ).const_get :INT_
    retval = Class.new target
    retval.bits   = bits
    retval.signed = signed
    retval
  end

  module_function :INT

end

class Module

  def const_missing_with_int( name )
    case name
    when :BYTE
      Hornetseye::INT  8,   SIGNED
    when :UBYTE
      Hornetseye::INT  8, UNSIGNED
    when :SINT
      Hornetseye::INT 16,   SIGNED
    when :USINT
      Hornetseye::INT 16, UNSIGNED
    when :INT
      Hornetseye::INT 32,   SIGNED
    when :UINT
      Hornetseye::INT 32, UNSIGNED
    when :LONG
      Hornetseye::INT 64,   SIGNED
    when :ULONG
      Hornetseye::INT 64, UNSIGNED
    else
      const_missing_without_int name
    end
  end

  alias_method_chain :const_missing, :int

end
