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
    retval.bits = bits
    retval.signed = signed
    retval
  end

  module_function :INT

  # 8-bit signed integer
  BYTE  = INT  8, SIGNED

  # 8-bit unsigned integer
  UBYTE = INT  8, UNSIGNED

  # 16-bit signed integer
  SINT  = INT 16, SIGNED

  # 16-bit unsigned integer
  USINT = INT 16, UNSIGNED

  # 32-bit signed integer
  INT   = INT 32, SIGNED

  # 32-bit unsigned integer
  UINT  = INT 32, UNSIGNED

  # 64-bit signed integer
  LONG  = INT 64, SIGNED

  # 64-bit unsigned integer
  ULONG = INT 64, UNSIGNED

end
