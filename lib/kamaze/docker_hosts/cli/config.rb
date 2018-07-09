# frozen_string_literal: true

require_relative '../cli'
require 'figgy'

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
class Kamaze::DockerHosts::Cli::Config < Figgy
  autoload :Pathname, 'pathname'

  class << self
    # @yield [Figgy::Configuration] an object to set things up with
    # @return [Figgy] a Figgy instance using the configuration
    def build
      config = Figgy::Configuration.new.tap do |c|
        c.preload = true
        c.root = roots.fetch(0)
        roots[1..-1].each { |path| c.add_root(roots.fetch(1)) }
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

    # Get default root paths.
    #
    # @return [Array<Pathname>]
    def roots
      [
        Pathname.new(__dir__).join('config'),
        Pathname.new('/etc').join($PROGRAM_NAME),
      ]
    end
  end
end
