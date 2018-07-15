# frozen_string_literal: true

require_relative '../docker_hosts'

# Configurator.
#
# @see Kamaze::DockerHosts::Config
class Kamaze::DockerHosts::Configurator
  autoload :Config, "#{__dir__}/configurator/config"

  # @param [Configurator::Config|String|Pathname] config
  def initialize(config)
    Config.tap do |klass|
      if config.is_a?(klass)
        @config = config
        return nil
      end

      @config = klass.build do |c|
        c.root = config.to_s
        c.add_root(klass.libconfdir)
      end
    end
  end

  # Get configured instance.
  #
  # Inherited class should configure and return target.
  #
  # @return [Configurator::Config]
  def call
    config
  end

  class << self
    # Get lib config path.
    #
    # @return [Pathname]
    def libconfdir
      Config.libconfdir
    end

    # Get system config path.
    #
    # @return [Pathname]
    def sysconfdir
      Config.sysconfdir
    end
  end

  protected

  # @return [Configurator::Config]
  attr_reader :config
end
