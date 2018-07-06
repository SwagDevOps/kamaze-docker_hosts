# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../docker_hosts'
require 'hosts'

# @see https://github.com/aef/hosts
class Kamaze::DockerHosts::File < Aef::Hosts::File
  autoload :Pathname, 'pathname'

  # Initializes a file.
  #
  # @param [String|Pathname|nil] path path to the hosts file
  def initialize(path = '/etc/hosts')
    reset
    self.path = path

    unless path.nil?
      read if self.path.file? and self.path.readable?
    end
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

  # Retrieves sections by name.
  #
  # @return [Array<Aef::Hosts::Section>]
  def sections(name)
    elements
      .keep_if { |elem| elem.is_a?(Aef::Hosts::Section) and elem.name == name }
  end

  # Denotes sections exist.
  #
  # @return [Boolean]
  def sections?(name)
    !sections(name).empty?
  end
end
