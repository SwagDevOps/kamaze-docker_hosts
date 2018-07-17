# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

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
