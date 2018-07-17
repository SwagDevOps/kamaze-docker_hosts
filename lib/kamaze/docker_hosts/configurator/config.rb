# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../configurator'
require 'figgy'
autoload :Pathname, 'pathname'

# Provide access to configuration files.
#
# Recognize missing methods and go look them up as a configuration key.
#
# To create a new instance, use ``Figgy.build``:
#
# ```ruby
# config = Figgy.build do |c|
#   c.root = '/path/to/my/configs'
# end
# config.foo.bar # read from /path/to/my/configs/foo.yml
# ```
#
# @see https://github.com/pd/figgy
class Kamaze::DockerHosts::Configurator::Config < Figgy
  # Get a Hash representation.
  #
  # @return [Hash]
  def to_h
    @store.keys.sort.map { |k| [k, self.public_send(k)] }.to_h
  end

  class << self
    # @yield [Figgy::Configuration] an object to set things up with
    # @return [Figgy] a Figgy instance using the configuration
    def build
      config = Figgy::Configuration.new.tap do |c|
        c.preload = true
        c.root = sysconfdir
        c.add_root(libconfdir)
        c.define_overlay :default, nil
      end

      yield(config) if block_given?
      new(config)
    end

    # Get name of current running program.
    #
    # @return [String]
    def progname
      $PROGRAM_NAME
    end

    # Get system config dir.
    #
    # @return [Pathname]
    def sysconfdir
      Pathname.new('/etc').join(progname)
    end

    # Get lib config dir.
    #
    # @return [Pathname]
    def libconfdir
      Pathname.new(__dir__).join('../configs').realpath
    end
  end
end
