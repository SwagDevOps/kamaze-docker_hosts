# frozen_string_literal: true

require_relative '../watcher'
require_relative '../../configurator'

class Kamaze::DockerHosts::Cli::Watcher
  # Watcher configurator
  #
  # @see Kamaze::DockerHosts::Configurator::Config
  class Configurator < Kamaze::DockerHosts::Configurator
    # Configure a watcher from given config.
    #
    # @param [Kamaze::DockerHosts::Configurator::Config|String|Pathname] config
    # @param [Kamaze::DockerHosts::Network] network
    def initialize(config, network, file = '/etc/hosts')
      super(config)

      @network = network
      @file    = file
    end

    # @return [Kamaze::DockerHosts::Cli::Watcher]
    def call
      setup
    end

    protected

    # @return [Kamaze::DockerHosts::Network]
    attr_reader :network

    # @return [Kamaze::DockerHosts::File]
    attr_reader :file

    # @return [Class]
    def target
      Kamaze::DockerHosts::Cli::Watcher
    end

    # @return [Kamaze::DockerHosts::Cli::Watcher]
    def setup
      target.new(network) do |configured|
        config.watcher.merge(file: self.file).each do |k, v|
          begin
            configured.public_send("#{k}=", v)
          rescue NoMethodError => e
            warn(e)
          end
        end
      end
    end
  end
end
