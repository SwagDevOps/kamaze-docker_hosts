# frozen_string_literal: true

# Easyfy system error number retrieval.
#
# The integer operating system error number corresponding
# to a particular error is available as the class constant
# ``Errno::error::Errno``.
module Kamaze::DockerHosts::Errno
  protected

  # Get errno code by name.
  #
  # @raise [NameError]
  # @return [Integer]
  def errno(name)
    Errno.const_get(name.to_sym).const_get(:Errno)
  end
end
