# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

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
