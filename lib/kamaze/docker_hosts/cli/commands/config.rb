# frozen_string_literal: true

require_relative '../commands'
require 'pp'
autoload 'JSON', 'json'

class Kamaze::DockerHosts::Cli
  # Display config (JSON representation)
  class Commands::Config < Command
    register 'config'
    configurable
    desc 'Display config (JSON representation)'

    include Kamaze::DockerHosts::Cli::Rouge

    def call(**options)
      configure(options)

      JSON.pretty_generate(config.to_h).tap do |json|
        output = tty?(:stdout) ? hl(json, :JSON) : json

        $stdout.puts(output)
      end
    end
  end
end
