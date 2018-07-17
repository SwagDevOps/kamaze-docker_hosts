# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../commands'
autoload 'JSON', 'json'

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

      options.fetch(:format).tap do |fmt|
        $stdout.puts self.__send__("render_#{fmt}", network)
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
      JSON.pretty_generate(network).tap do |json|
        return tty?(:stdout) ? hl(json, :JSON) : json
      end
    end
  end
end
