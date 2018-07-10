# frozen_string_literal: true

require_relative '../network'
require_relative '../configurator'

module Kamaze::DockerHosts
  # Network config
  #
  # @see Kamaze::DockerHosts::Config
  class Network::Configurator < Configurator
    autoload :Docker, 'docker'

    # Get configured network.
    #
    # @return [Kamaze::DockerHosts::Network]
    attr_reader :network

    # Configure a network from given config.
    #
    # @param [Kamaze::DockerHosts::Config|String|Pathname] config
    def initialize(config)
      super
      @network = network_setup
    end

    protected

    # @return [self]
    #
    # @see https://github.com/swipely/docker-api#host
    # @see https://github.com/swipely/docker-api#ssl
    def configure_docker
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
        # apply network config
        config.network.extension.tap do |extension|
          network.extension = extension unless extension.to_s.empty?
        end
      end
    end
  end
end
