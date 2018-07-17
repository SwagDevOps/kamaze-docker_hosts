# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../network'
require_relative '../configurator'

module Kamaze::DockerHosts
  # Network config
  #
  # @see Kamaze::DockerHosts::Config
  class Network::Configurator < Configurator
    autoload :Docker, 'docker'

    # @return [Kamaze::DockerHosts::Network]
    def call
      setup
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
    def setup
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
