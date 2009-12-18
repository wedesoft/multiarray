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
    retval = Class.new INT_
    retval.bits   = bits
    retval.signed = signed
    retval
  end

  module_function :INT

  BYTE  = INT  8, SIGNED
  UBYTE = INT  8, UNSIGNED
  SINT  = INT 16, SIGNED
  USINT = INT 16, UNSIGNED
  INT   = INT 32, SIGNED
  UINT  = INT 32, UNSIGNED
  LONG  = INT 64, SIGNED
  ULONG = INT 64, UNSIGNED

end
