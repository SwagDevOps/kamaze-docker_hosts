# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../docker_hosts'
require 'hosts'

# @abstract
# @see https://github.com/aef/hosts
class Kamaze::DockerHosts::BaseFile < Aef::Hosts::File
  autoload :Pathname, 'pathname'

  # Initializes a file.
  #
  # @param [String|Pathname|nil] path path to the hosts file
  def initialize(path = '/etc/hosts')
    reset
    self.path = path
    autoread
  end

  class << self
    # Parses a hosts file given as String.
    #
    # @param [String] data a String representation of the hosts file
    # @return [Aef::Hosts::File] a file
    def parse(data)
      new(nil).parse(data)
    end
  end

  protected

  # Automatically read ``path``.
  #
  # @return [self]
  def autoread
    unless path.nil?
      read if self.path.file? and self.path.readable?
    end

    self
  end
end
