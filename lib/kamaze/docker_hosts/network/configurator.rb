# frozen_string_literal: true

require_relative '../network'
require_relative '../config'

# Network configurator.
#
# @see Kamaze::DockerHosts::Config
class Kamaze::DockerHosts::Network::Configurator
  # Get configured network.
  #
  # @return [Kamaze::DockerHosts::Network]
  attr_reader :network

  # Configure a network from given config.
  #
  # @param [Kamaze::DockerHosts::Config|String|Pathname] config
  def initialize(config)
    config_class = Kamaze::DockerHosts::Config
    # rubocop:disable Style/ConditionalAssignment
    if config.is_a?(config_class)
      @config = config
    else
      @config = config_class.build do |c|
        c.add_root(config.to_s)
      end
    end
    # rubocop:enable Style/ConditionalAssignment

    @network = network_setup
    yield(network) if block_given?
  end

  protected

  # @return [Kamaze::DockerHosts::Config]
  attr_reader :config

  # @return [self]
  #
  # @see https://github.com/swipely/docker-api#host
  # @see https://github.com/swipely/docker-api#ssl
  def configure_docker
    require 'docker'

    config.docker.tap do |config|
      [:options, :url].each do |method|
        config.public_send(method).tap do |val|
          Docker.public_send("#{method}=", val) if val
        end
      end
    end

    self
  end

  # @return [Kamaze::DockerHosts::Network]
  def network_setup
    configure_docker
    Kamaze::DockerHosts::Network.new.tap do |network|
      if config
        # apply network config
        config.network.extension.tap do |extension|
          network.extension = extension unless extension.to_s.empty?
        end
      end
    end
  end
end
