# frozen_string_literal: true

require_relative '../commands'

class Kamaze::DockerHosts::Cli
  # Display network status
  class Commands::Network < Command
    register 'network'
    enable_network
    desc 'Display network status'
    option :format, \
           desc: 'Format',
           values: %w[json text],
           default: :json

    include Kamaze::DockerHosts::Cli::Rouge

    def call(**options)
      configure(options)

      halt(:ENETDOWN, 'Network unavailable.') unless network.available?
      halt(:NOERROR) if network.empty?

      options.fetch(:format).tap do |type|
        $stdout.puts self.__send__("render_#{type}", network)
      end
    end

    protected

    # Render given network as text.
    #
    # @param [Hash|Kamaze::DockerHosts::Network] network
    # @return [String]
    def render_text(network)
      network.to_s
    end

    # Render given network as json.
    #
    # @param [Hash|Kamaze::DockerHosts::Network] network
    # @return [String]
    def render_json(network)
      json = JSON.pretty_generate(network)

      tty?(:stdout) ? hl(json, :JSON) : json
    end
  end
end
