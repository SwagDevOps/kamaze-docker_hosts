# frozen_string_literal: true

require_relative '../docker_hosts'

# Configurator.
#
# @see Kamaze::DockerHosts::Config
class Kamaze::DockerHosts::Configurator
  autoload :Pathname, 'pathname'
  autoload :Config, "#{__dir__}/configurator/config"

  # @return [Kamaze::DockerHosts::Config]
  attr_reader :config

  # @param [Kamaze::DockerHosts::Config|String|Pathname] config
  def initialize(config)
    Config.tap do |klass|
      if config.is_a?(klass)
        @config = config
        return nil
      end

      @config = klass.build do |c|
        c.root = config.to_s
        klass.roots.each { |path| c.add_root(path) }
      end
    end
  end

  # Get default root paths.
  #
  # @return [Array<Pathname>]
  class << self
    def roots
      Config.roots
    end
  end
end
