# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../commands'

class Kamaze::DockerHosts::Cli
  # Display hosts
  class Commands::Hosts < Command
    register 'hosts'
    enable_network
    desc 'Display hosts'
    option :input, \
           desc: 'File read',
           aliases: ['-i'],
           default: '/etc/hosts'

    include Kamaze::DockerHosts::Cli::Rouge

    def call(**options)
      configure(options)

      read(options.fetch(:input)).update!(network).tap do |content|
        output = tty?(:stdout) ? hl(content, :Conf) : content
        method = tty?(:stdout) ? :write : :puts

        $stdout.public_send(method, output)
      end
    end

    protected

    # Read file.
    #
    # @return [Kamaze::DockerHosts::File]
    def read(file)
      Kamaze::DockerHosts::File.new(file)
    end
  end
end
